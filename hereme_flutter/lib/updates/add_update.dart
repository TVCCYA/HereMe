import 'package:animator/animator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../constants.dart';

class AddLatest extends StatefulWidget {
  @override
  _AddLatestState createState() => _AddLatestState();
}

class _AddLatestState extends State<AddLatest> {
  bool showSpinner = false;
  File mediaFile;
  bool _isButtonDisabled = true;
  int creationDate = DateTime.now().millisecondsSinceEpoch;
  String title;

  _isValid() {
    if ((title != null && title.isNotEmpty && title.trim().length != 0) || mediaFile != null) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: circularProgress(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: Text(
            'Add Latest',
            textAlign: TextAlign.left,
            style: kAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft),
            onPressed: () {
              Navigator.pop(context);
            },
            color: kColorBlack71,
            splashColor: kColorExtraLightGray,
            highlightColor: Colors.transparent,
          ),
          actions: <Widget>[
            _isButtonDisabled
                ? SizedBox() : Animator(
              duration: Duration(milliseconds: 200),
              tween: Tween(begin: 0.8, end: 1.0),
              curve: Curves.easeInOutQuad,
              cycles: 1,
              builder: (anim) => Transform.scale(
                scale: anim.value,
                child: Center(
                  child: FlatButton(
                    child: Text(
                      'Done',
                      style: kAppBarTextStyle.copyWith(color: kColorBlue),
                    ),
                    onPressed: () => _addUpdate(),
                    splashColor: kColorExtraLightGray,
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    maxLength: 200,
                    maxLines: 5,
                    cursorColor: kColorLightGray,
                    onChanged: (value) {
                      title = value;
                      _isValid();
                    },
                    focusNode: null,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    style: kDefaultTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      labelText: 'Headline',
                      hintText: 'Spred the news...',
                      hintStyle: kDefaultTextStyle.copyWith(
                        color: kColorLightGray,
                      ),
                      labelStyle: kAppBarTextStyle.copyWith(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12.0, bottom: 48.0),
                    child: mediaFile != null
                        ? ReusableCard(
                            imageFile: mediaFile,
                            onTap: () {
                              _openPhotoLibrary();
                            },
                          ) : SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: SafeArea(
          child: Container(
            height: 50,
            width: screenWidth,
            decoration: BoxDecoration(
              border: Border.all(color: kColorExtraLightGray),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.only(right: 4.0, left: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 40,
                    child: FlatButton(
                      onPressed: () => _openPhotoLibrary(),
                      child:
                          Icon(FontAwesomeIcons.solidImages, color: kColorBlack71),
                      splashColor: kColorExtraLightGray,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                  mediaFile != null
                      ? ButtonTheme(
                          minWidth: 40,
                          child: FlatButton(
                            onPressed: () => _removeMediaFile(),
                            child: Text('Remove',
                                style: kAppBarTextStyle.copyWith(
                                    color: kColorRed, fontSize: 16)),
                            splashColor: kColorExtraLightGray,
                            highlightColor: Colors.transparent,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _removeMediaFile() {
    if (this.mounted)
      setState(() {
        mediaFile = null;
      });
    _isValid();
  }

  _openPhotoLibrary() async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100).then(
      (image) {
        _cropImage(image);
        if (this.mounted)
          setState(() {
            showSpinner = false;
          });
      },
    );
  }

  _cropImage(File imageFile) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
    );
    if (this.mounted)
      setState(() {
        mediaFile = mediaFile;
        showSpinner = false;
        _isValid();
      });
  }

  Future _uploadProfileImageToFirebase(File mediaFile) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final String currentUserUid = currentUser.uid;
    final id = Uuid().v4();
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    StorageUploadTask uploadFile = _storage
        .ref()
        .child('update_images/$currentUserUid/$id')
        .putFile(mediaFile);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('update_images')
            .child(currentUserUid)
            .child(id)
            .getDownloadURL();

        updateRef
            .document(currentUserUid)
            .collection('posts')
            .document(id)
            .setData({
          'photoUrl': downloadUrl,
          'type': 'photo',
          'id': id,
          'uid': currentUserUid,
          'creationDate': creationDate,
          'title': title ?? '',
          'likes': {},
        }).whenComplete(() {
          print('User Photo Added');
          if (this.mounted)
            setState(() {
              showSpinner = false;
            });
          Navigator.pop(context);
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

  _uploadText() {
    final String currentUserUid = currentUser.uid;
    final id = Uuid().v4();
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    updateRef
        .document(currentUserUid)
        .collection('posts')
        .document(id)
        .setData({
      'type': 'text',
      'id': id,
      'uid': currentUserUid,
      'creationDate': creationDate,
      'title': title.trim(),
      'likes': {},
    }).whenComplete(() {
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      Navigator.pop(context);
    });
  }

  _addUpdate() {
    if (mediaFile != null) {
      _uploadProfileImageToFirebase(mediaFile);
    } else {
      _uploadText();
    }
  }
}
