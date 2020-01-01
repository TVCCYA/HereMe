import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';

final _firestore = Firestore.instance;

class PhotoAdd extends StatefulWidget {
  final String uid;

  PhotoAdd({this.uid});

  @override
  _PhotoAddState createState() => _PhotoAddState();
}

class _PhotoAddState extends State<PhotoAdd> {
  bool showSpinner = false;
  bool _isButtonDisabled = true;
  File mediaFile;

  @override
  void initState() {
    super.initState();
  }

  void isValid() {
    if (mediaFile != null) {
      if (this.mounted) setState(() {
        _isButtonDisabled = false;
      });
    } else {
      if (this.mounted) setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    final polaroidPic = GestureDetector(
      onTap: () => _showPhotoActionSheet(context),
      child: Image.asset(
        'images/add-image.png',
        height: (screenHeight / 5) / 1.75,
        width: (screenHeight / 5) / 1.75,
        color: Colors.white,
      ),
    );

    return Scaffold(
      backgroundColor: kColorRed,
      appBar: AppBar(
        backgroundColor: kColorRed,
        elevation: 0.0,
        centerTitle: false,
        title: Text(
          'Spred',
          textAlign: TextAlign.left,
          style: kAppBarTextStyle.copyWith(
            color: kColorOffWhite,
            fontSize: 25.0,
          ),
        ),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorRed),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Choose a\nProfile Image',
                        textAlign: TextAlign.center,
                        style: kAppBarTextStyle.copyWith(
                          fontSize: 26.0,
                          color: kColorOffWhite,
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      mediaFile != null
                          ? ReusableCard(
                              imageFile: mediaFile,
                              cardSize: screenHeight / 4,
                              onTap: () {
                                _openPhotoLibrary();
                              },
                            )
                          : polaroidPic,
                      SizedBox(
                        height: 24.0,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: FlatButton.icon(
                          onPressed: () => _isButtonDisabled
                              ? print('Disabled')
                              : _uploadImageToFirebase(mediaFile),
                          splashColor: _isButtonDisabled
                              ? Colors.transparent
                              : kColorOffWhite,
                          highlightColor: Colors.transparent,
                          icon: Icon(
                            _isButtonDisabled
                                ? FontAwesomeIcons.arrowAltCircleUp
                                : FontAwesomeIcons.arrowAltCircleRight,
                            size: 30.0,
                            color: _isButtonDisabled
                                ? Colors.white
                                : Colors.white,
                          ),
                          label: Text(
                            _isButtonDisabled
                                ? 'Add Image'
                                : 'Complete',
                            style: kDefaultTextStyle.copyWith(
                                color: _isButtonDisabled
                                    ? Colors.white
                                    : Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _openPhotoLibrary() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then(
      (profilePic) {
        _cropImage(profilePic);
        if (this.mounted) setState(() {
          showSpinner = false;
        });
      },
    );
  }

  _openCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then(
      (profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic);
          if (this.mounted) setState(() {
            showSpinner = false;
          });
        } else {
          if (this.mounted) setState(() {
            showSpinner = false;
          });
        }
      },
    );
  }

  Future _uploadImageToFirebase(File mediaFile) async {
    final ref = _firestore.collection('users');
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted) setState(() {
      showSpinner = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    StorageUploadTask uploadFile =
    _storage.ref().child('profile_images_flutter/$uid').putFile(mediaFile);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then(
          (uploaded) async {
        if (succeed == true) {
          final downloadUrl = await _storage
              .ref()
              .child('profile_images_flutter')
              .child(uid)
              .getDownloadURL();

          _savePhotoSharedPref(downloadUrl);

          Map<String, dynamic> photoUrl = <String, dynamic>{
            'profileImageUrl': downloadUrl,
          };
          ref.document(uid)
              .updateData(photoUrl).whenComplete(() {
            print('Recent Upload Added');
            if (this.mounted) setState(() {
              showSpinner = false;
            });
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false);
          }).catchError(
                (e) => kShowAlert(
              context: context,
              title: 'Upload Failed',
              desc:
              'Unable to upload your thumbnail image, please try again later',
              buttonText: 'Try Again',
              onPressed: () => Navigator.pop(context),
                  color: kColorRed
            ),
          );
        }
      },
    );
  }

  _savePhotoSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', '$downloadUrl');
  }

  Future<Null> _cropImage(File imageFile) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1.0,
        ratioY: 1.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    );
    if (this.mounted) setState(() {
      mediaFile = mediaFile;
      showSpinner = false;
      isValid();
    });
  }

  void _showPhotoActionSheet(context) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Photo Library',
        iconData: FontAwesomeIcons.images,
        onTap: () async {
          _openPhotoLibrary();
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Camera',
        iconData: FontAwesomeIcons.cameraRetro,
        onTap: () async {
          _openCamera();
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel',
        iconData: FontAwesomeIcons.times,
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }
}
