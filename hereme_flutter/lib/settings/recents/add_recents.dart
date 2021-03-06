import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'package:hereme_flutter/utils/reusable_registration_textfield.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

class AddRecent extends StatefulWidget {
  @override
  _AddRecentState createState() => _AddRecentState();
}

class _AddRecentState extends State<AddRecent> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  final _urlFocus = FocusNode();
  final _titleFocus = FocusNode();
  String url;
  String title;
  bool _isButtonDisabled = true;
  File mediaFile;

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  void isValid() {
    if ((url.isNotEmpty && !url.contains(' ') && url.contains('https://')) && title.isNotEmpty && mediaFile != null) {
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
        key: _scaffoldKey,
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
            color: kColorBlack62,
            splashColor: kColorExtraLightGray,
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
                valueColor: AlwaysStoppedAnimation<Color>(kColorRed),
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
                                kShowSnackbar(
                                  key: _scaffoldKey,
                                  text: 'https://example.com',
                                  backgroundColor: kColorRed
                                );
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
                              ? CircleCard(
                                  imageFile: mediaFile,
                                  size: screenHeight / 5,
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
                              ? print('disabled')
                              : _uploadRecentToFirebase(mediaFile);
                          if (url.contains(' ')) {
                            kShowSnackbar(
                                key: _scaffoldKey,
                                text: 'URL cannot contain spaces',
                                backgroundColor: kColorRed
                            );
                          }
                          if (!url.contains('https://')) {
                            kShowSnackbar(
                                key: _scaffoldKey,
                                text: 'URL format: https://example.com',
                                backgroundColor: kColorRed
                            );
                          }
                        },
                        splashColor: _isButtonDisabled
                            ? Colors.transparent
                            : kColorExtraLightGray,
                        highlightColor: Colors.transparent,
                        icon: Icon(
                          _isButtonDisabled
                              ? FontAwesomeIcons.arrowAltCircleUp
                              : FontAwesomeIcons.arrowAltCircleRight,
                          size: 30.0,
                          color: _isButtonDisabled
                              ? kColorLightGray
                              : kColorRed,
                        ),
                        label: Text(
                          _isButtonDisabled ? 'Not Done' : 'Add Recent',
                          style: kDefaultTextStyle.copyWith(
                              color: _isButtonDisabled
                                  ? kColorLightGray
                                  : kColorRed),
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
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100).then(
      (profilePic) {
        _cropImage(profilePic);
        if (this.mounted) setState(() {
          showSpinner = false;
        });
      },
    );
  }

  _cropImage(File imageFile) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100
    );
    if (this.mounted) setState(() {
      mediaFile = mediaFile;
      showSpinner = false;
      isValid();
    });
  }

  _uploadRecentToFirebase(File mediaFile) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;
    final filename = Uuid().v4();

    if (this.mounted) setState(() {
      showSpinner = true;
      _isButtonDisabled = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    StorageUploadTask uploadFile =
        _storage.ref().child('recent_upload_thumbnail/$uid/$filename').putFile(mediaFile);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then(
      (uploaded) async {
        if (succeed == true) {
          final downloadUrl = await _storage
              .ref()
              .child('recent_upload_thumbnail')
              .child(uid)
              .child(filename)
              .getDownloadURL();

          Map<String, dynamic> photoUrl = <String, dynamic>{
            'thumbnailImageUrl': downloadUrl,
            'storageFilename': filename,
            'title': title,
            'url': url,
            'creationDate': DateTime.now().millisecondsSinceEpoch,
          };
          recentUploadsRef.document(uid).collection('recents').document(filename)
              .setData(photoUrl).whenComplete(() {
            if (this.mounted) setState(() {
              showSpinner = false;
            });
            Navigator.pop(context);
          }).catchError(
            (e) {
              kShowAlert(
                context: context,
                title: 'Upload Failed',
                desc:
                'Unable to upload your thumbnail image, please try again later',
                buttonText: 'Try Again',
                onPressed: () => Navigator.pop(context),
              );
              if (this.mounted) setState(() {
                _isButtonDisabled = false;
              });
            }
          );
        }
      },
    );
  }
}
