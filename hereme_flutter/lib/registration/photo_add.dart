import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double topProfileHeight = screenHeight / 4;
    double topHalf = topProfileHeight * 0.75;
    double profileImageSize = topHalf * 0.75;

    final polaroidPic = GestureDetector(
      onTap: () => _showPhotoActionSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(FontAwesomeIcons.solidUserCircle, size: (screenHeight / 5) / 1.75, color: Colors.white),
          SizedBox(height: 16.0),
          Text('Add Photo', style: kDefaultTextStyle.copyWith(color: kColorExtraLightGray),)
        ],
      ),
    );

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: circularProgress(),
      child: Scaffold(
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
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  height: 20.0,
                ),
                mediaFile != null
                    ? CircleCard(
                        imageFile: mediaFile,
                        size: profileImageSize,
                        onTap: () {
                          _openPhotoLibrary();
                        },
                      )
                    : polaroidPic,
              ],
            ),
          ),
        ),
        bottomSheet: _isButtonDisabled ? SizedBox() : SafeArea(
          child: Container(
            height: 50,
            width: screenWidth,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: kColorExtraLightGray)),
              color: kColorRed,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ButtonTheme(
                minWidth: 40,
                child: FlatButton(
                  onPressed: () => _uploadImageToFirebase(mediaFile),
                  child: Text('Next',
                      style: kAppBarTextStyle.copyWith(
                          color: Colors.white, fontSize: 16)),
                  splashColor: kColorDarkRed,
                  highlightColor: Colors.transparent,
                ),
              )
            ),
          ),
        ),
      ),
    );
  }

  _openPhotoLibrary() async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100).then(
      (profilePic) {
        _cropImage(profilePic);
        if (this.mounted) setState(() {
          showSpinner = false;
        });
      },
    );
  }

  _openCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 100).then(
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

  _cropImage(File imageFile) async {
    mediaFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        compressQuality: 100,
        cropStyle: CropStyle.circle
    );
    if (this.mounted) setState(() {
      mediaFile = mediaFile;
      showSpinner = false;
      isValid();
    });
  }

  Future _uploadImageToFirebase(File mediaFile) async {
    final ref = _firestore.collection('users');
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted) setState(() {
      showSpinner = true;
    });
    final user = await FirebaseAuth.instance.currentUser();
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
          ref.document(uid).updateData(photoUrl).whenComplete(() {
            print('Recent Upload Added');
            if (this.mounted) setState(() {
              showSpinner = false;
            });
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (BuildContext context) => BottomBar()),
                    (Route<dynamic> route) => false);
          }).catchError(
                (e) => kShowAlert(
              context: context,
              title: 'Upload Failed',
              desc:
              'Unable to upload your profile image, please try again later',
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
