import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'package:hereme_flutter/utils/reusable_registration_textfield.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

final _firestore = Firestore.instance;

class AddRecent extends StatefulWidget {
  @override
  _AddRecentState createState() => _AddRecentState();
}

class _AddRecentState extends State<AddRecent> {
  bool showSpinner = false;
  final _urlFocus = FocusNode();
  final _titleFocus = FocusNode();
  String url;
  String title;
  bool _isButtonDisabled;
  File mediaFile;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = true;
  }

  void isValid() {
    if ((url.isNotEmpty && !url.contains(' ') && url.contains('https://')) && title.isNotEmpty && mediaFile != null) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    final polaroidPic = GestureDetector(
      onTap: () => _openPhotoLibrary(),
      child: Image.asset(
        'images/add-image.png',
        height: (screenHeight / 5) / 2 - 12,
        width: (screenHeight / 5) / 2 - 12,
      ),
    );

    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft),
            onPressed: () {
              Navigator.pop(context);
            },
            color: kColorBlack105,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          title: Text(
            'Add Recent Upload',
            style: kAppBarTextStyle,
          ),
          backgroundColor: Colors.white,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kColorPurple),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (_) {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'URL',
                          style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        ),
                        Expanded(
                          child: ReusableRegistrationTextField(
                            hintText: 'Recent Upload URL',
                            focusNode: null,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            icon: null,
                            onSubmitted: (v) {
                              if (url.contains('https://')) {
                                FocusScope.of(context).requestFocus(_urlFocus);
                              } else {
                                kErrorFlushbar(context: context, errorText: 'https://example.com');
                              }
                            },
                            onChanged: (value) {
                              url = value;
                              isValid();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: <Widget>[
                        Text(
                          'Title',
                          style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        ),
                        Expanded(
                          child: ReusableRegistrationTextField(
                            hintText: 'Enter Clickbait',
                            focusNode: _urlFocus,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            icon: null,
                            onSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_titleFocus);
                            },
                            onChanged: (value) {
                              title = value;
                              isValid();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Select Thumbnail',
                            style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          mediaFile != null
                              ? ReusableCard(
                                  imageFile: mediaFile,
                                  cardSize: screenHeight / 5,
                                  onTap: () {
                                    _openPhotoLibrary();
                                  },
                                )
                              : polaroidPic,
                        ],
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.topRight,
                      child: FlatButton.icon(
                        onPressed: () {
                          _isButtonDisabled
                              ? kErrorFlushbar(context: context, errorText: 'https://example.com')
                              : _uploadImageToFirebase(mediaFile);
                        },
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
                              ? kColorLightGray
                              : kColorPurple,
                        ),
                        label: Text(
                          _isButtonDisabled ? 'Not Done' : 'Add Recent',
                          style: kDefaultTextStyle.copyWith(
                              color: _isButtonDisabled
                                  ? kColorLightGray
                                  : kColorPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
        setState(() {
          showSpinner = false;
        });
      },
    );
  }

  Future<Null> _cropImage(File imageFile) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      mediaFile = mediaFile;
      showSpinner = false;
      isValid();
    });
  }

  Future _uploadImageToFirebase(File mediaFile) async {
    final ref = _firestore.collection('recentUploads');
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;
    final filename = Uuid().v4();

    setState(() {
      showSpinner = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    StorageUploadTask uploadFile =
        _storage.ref().child('recent_upload_thumbnail/$filename').putFile(mediaFile);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then(
      (uploaded) async {
        if (succeed == true) {
          final downloadUrl = await _storage
              .ref()
              .child('recent_upload_thumbnail')
              .child(filename)
              .getDownloadURL();

//          _savePhotoSharedPref(downloadUrl);

          Map<String, dynamic> photoUrl = <String, dynamic>{
            'thumbnailImageUrl': downloadUrl,
            'storageFilename': filename,
            'title': title,
            'url': url,
            'creationDate': DateTime.now().millisecondsSinceEpoch * 1000,
          };
          ref.document(uid).collection('recents').document(filename)
              .setData(photoUrl).whenComplete(() {
            print('Recent Upload Added');
            setState(() {
              showSpinner = false;
            });
            Navigator.pop(context);
          }).catchError(
            (e) => kShowAlert(
                  context: context,
                  title: 'Upload Failed',
                  desc:
                      'Unable to upload your thumbnail image, please try again later',
                  buttonText: 'Try Again',
                  onPressed: () => Navigator.pop(context),
                ),
          );
        }
      },
    );
  }
}
