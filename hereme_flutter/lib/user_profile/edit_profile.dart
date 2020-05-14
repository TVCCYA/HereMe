import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/user_profile/edit_bio.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final Color color;
  final Color color2;
  EditProfile({this.color, this.color2});
  @override
  _EditProfileState createState() => _EditProfileState(
        color: this.color,
        color2: this.color2
      );
}

class _EditProfileState extends State<EditProfile> {
  Color color;
  Color color2;
  _EditProfileState({this.color, this.color2});

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController usernameController = TextEditingController();
  File mediaFile;

  bool showSpinner = false;
  String defaultBackground = 'images/bubbly.png';
  String profileImageUrl = currentUser.profileImageUrl;
  String backgroundImageUrl = currentUser.backgroundImageUrl;
  String username;
  bool changedProfileImage = false;
  bool changedBackgroundImage = false;
  bool changedUsername = false;

  _getPaletteColor() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(profileImageUrl),
    );
    final muted = generator.mutedColor.color;
    final dominant = generator.dominantColor.color;
    final first = generator.colors.first;
    final last = generator.colors.last;
    if (this.mounted)
      setState(() {
        color = muted != null ? muted : dominant != null ? dominant : first;
        color2 = dominant != null ? dominant : muted != null ? muted : last;
      });
  }

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  bool didUpdateUserInfo() {
    if (changedProfileImage || changedBackgroundImage || changedUsername) {
      return true;
    } else {
      return null;
    }
  }

  updateUserInfo() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: circularProgress(),
      child: Theme(
        data: kTheme(context),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            title: Text(
              'Edit Profile',
              style: kAppBarTextStyle,
            ),
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft,
                  color: kColorBlack62, size: 20),
              onPressed: () {
                Navigator.pop(context, 'ok');
              },
            ),
            actions: <Widget>[
              Center(
                  child: FlatButton(
                    child: Text(
                      'Done',
                      style: kAppBarTextStyle.copyWith(color: kColorBlue),
                    ),
                    onPressed: () => _handleDone(),
                    splashColor: kColorExtraLightGray,
                    highlightColor: Colors.transparent,
                  ),
                ),
            ],
          ),
          body: Container(
            height: screenHeight,
            width: screenWidth,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _changePhotoActionSheet(false),
                    child: Container(
                      height: screenHeight / 3 + 25,
                      width: screenWidth,
                      child: Stack(
                        children: <Widget>[
                          backgroundImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: backgroundImageUrl,
                                  fit: BoxFit.cover,
                                  height: screenHeight / 2,
                                  width: screenWidth,
                                )
                              : Container(
                              decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomLeft,
                                colors: [
                                  color,
                                  color2,
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Change Background Photo',
                                style:
                                    kUsernameTextStyle.copyWith(fontSize: 16.0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _changePhotoActionSheet(true),
                        child: Column(
                          children: <Widget>[
                            cachedUserResultImage(
                              currentUser.profileImageUrl != null
                                  ? profileImageUrl
                                  : '',
                              screenWidth / 5,
                              true,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Change Profile Photo',
                              style: kAppBarTextStyle.copyWith(
                                  fontSize: 16.0, color: kColorBlue),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 88.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        EditProfileContainer(
                          title: 'Name',
                          child: TextField(
                            cursorColor: kColorExtraLightGray,
                            onChanged: (value) {
                              username = value;
                            },
                            focusNode: null,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            style: kDefaultTextStyle,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: currentUser.username,
                              hintStyle: kDefaultTextStyle.copyWith(
                                color: kColorLightGray,
                              ),
                              labelStyle:
                                  kAppBarTextStyle.copyWith(fontSize: 16.0),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreateDisplayName(showBackButton: true))),
                          child: EditProfileContainer(
                            title: 'Username',
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 12.0, bottom: 16.0),
                              child: Text(
                                currentUser.displayName ?? '',
                                style: kDefaultTextStyle.copyWith(
                                    color: Color.fromRGBO(
                                        currentUser.red ?? 71,
                                        currentUser.green ?? 71,
                                        currentUser.blue ?? 71,
                                        1.0)),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) => EditBio())),
                          child: EditProfileContainer(
                            title: 'Bio',
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  currentUser.bio != ''
                                      ? Text(
                                          currentUser.bio,
                                          style: kDefaultTextStyle,
                                        )
                                      : Text(
                                          'Bio',
                                          style: kDefaultTextStyle.copyWith(
                                              color: kColorLightGray),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _handleDone() {
    if (username != null) {
      _submitUpdateNameChange();
    } else {
      if (this.mounted) setState(() {
        showSpinner = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        if (this.mounted) setState(() {
          showSpinner = false;
        });
        Navigator.pop(context, 'ok');
      });
    }
  }

  _submitUpdateNameChange() {
    username.length > 0
        ? _handleNameChange()
        : kShowSnackbar(
        key: _scaffoldKey,
        text: 'Name cannot be empty',
        backgroundColor: kColorRed);
  }

  _handleNameChange() async {
    if (this.mounted) setState(() {
      showSpinner = true;
    });
    final userReference = usersRef.document(currentUser.uid);
    Map<String, String> nameData = <String, String>{
      'username': username.trim(),
    };
    userReference.updateData(nameData).whenComplete(() {
      updateUserInfo();
      _updatePreferences(context);
      Future.delayed(Duration(seconds: 2), () {
        if (this.mounted) setState(() {
          changedUsername = true;
          showSpinner = false;
        });
        Navigator.pop(context, 'ok');
      });
    }).catchError((e) => print(e));
  }

  _updatePreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  _changePhotoActionSheet(bool isChangingProfileImage) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    if (!isChangingProfileImage && backgroundImageUrl != null) {
      sheets.add(ReusableBottomActionSheetListTile(
        title: 'Remove Background',
        iconData: FontAwesomeIcons.trash,
        onTap: () {
          _removeBackgroundImage();
          Navigator.pop(context);
        },
        color: kColorRed,
      ));
    }
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Photo Library',
        iconData: FontAwesomeIcons.images,
        onTap: () async {
          _openPhotoLibrary(isChangingProfileImage);
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Camera',
        iconData: FontAwesomeIcons.cameraRetro,
        onTap: () async {
          _openCamera(isChangingProfileImage);
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

  _removeBackgroundImage() {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    usersRef.document(currentUser.uid).updateData({
      'backgroundImageUrl': FieldValue.delete(),
    }).whenComplete(() {
      updateUserInfo();
      _storage
          .ref()
          .child('profile_background_image/${currentUser.uid}')
          .delete();
      setState(() {
        backgroundImageUrl = null;
      });
      _saveBackgroundSharedPref(null);
    });
  }

  _openPhotoLibrary(bool isChangingProfileImage) async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100)
        .then(
      (profilePic) {
        _cropImage(profilePic, isChangingProfileImage);
      },
    );
  }

  _openCamera(bool isChangingProfileImage) async {
    await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 100)
        .then(
      (profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic, isChangingProfileImage);
        }
      },
    );
  }

  _cropImage(File imageFile, bool isChangingProfileImage) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
      cropStyle:
          isChangingProfileImage ? CropStyle.circle : CropStyle.rectangle,
    );
    if (mediaFile == null) {
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
    } else {
      isChangingProfileImage
          ? _uploadProfileImageToFirebase(mediaFile)
          : _uploadBackgroundImageToFirebase(mediaFile);
    }
  }

  _uploadProfileImageToFirebase(File profileImage) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    StorageUploadTask uploadFile = _storage
        .ref()
        .child('profile_images_flutter/${currentUser.uid}')
        .putFile(profileImage);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_images_flutter')
            .child(currentUser.uid)
            .getDownloadURL();

        _saveProfileImageSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          'profileImageUrl': '$downloadUrl'
        };
        final ref = usersRef.document(currentUser.uid);
        ref.updateData(photoUrl).whenComplete(() {
          updateUserInfo();
          if (this.mounted)
            setState(() {
              profileImageUrl = downloadUrl;
              showSpinner = false;
              changedProfileImage = true;
            });
          _getPaletteColor();
          userLocationsRef.document(currentUser.uid).updateData(photoUrl);
        }).catchError(
          (e) => kShowAlert(
            context: context,
            title: 'Upload Failed',
            desc: 'Unable to upload your profile image, please try again later',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          ),
        );
      }
    });
  }

  _saveProfileImageSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', downloadUrl);
  }

  _uploadBackgroundImageToFirebase(File backgroundImage) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });

    StorageUploadTask uploadFile = _storage
        .ref()
        .child('profile_background_image/${currentUser.uid}')
        .putFile(backgroundImage);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_background_image')
            .child(currentUser.uid)
            .getDownloadURL();

        _saveBackgroundSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          'backgroundImageUrl': '$downloadUrl'
        };

        usersRef
            .document(currentUser.uid)
            .updateData(photoUrl)
            .whenComplete(() {
          updateUserInfo();
          if (this.mounted)
            setState(() {
              backgroundImageUrl = downloadUrl;
              showSpinner = false;
              changedBackgroundImage = true;
            });
        }).catchError(
          (e) => kShowAlert(
            context: context,
            title: 'Upload Failed',
            desc:
                'Unable to upload your background image, please try again later',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          ),
        );
      }
    });
  }

  _saveBackgroundSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('backgroundImageUrl', downloadUrl);
  }
}

class EditProfileContainer extends StatelessWidget {
  final Widget child;
  final String title;
  EditProfileContainer({this.child, this.title});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kColorExtraLightGray))),
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
            child,
          ],
        ),
      ),
    );
  }
}
