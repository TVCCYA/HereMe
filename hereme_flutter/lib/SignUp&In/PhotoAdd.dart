import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../TabController.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';

class PhotoAdd extends StatefulWidget {
  final String uid;

  PhotoAdd({Key key, this.uid}) : super(key: key);

  @override
  _PhotoAddState createState() => _PhotoAddState();
}

class _PhotoAddState extends State<PhotoAdd> {
  bool hideContinueButton = true;
  bool showLibCamButtons = false;
  bool showProgIndicator = false;
  String pickerPhoto;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final polaroidPic = new Container(
      child: new ImageIcon(new AssetImage("images/polaroidProPic180.png"),
          size: screenWidth * 0.25, color: Colors.black),
    );

    final userPhoto = pickerPhoto != null ? new Container(
      padding: EdgeInsets.fromLTRB(
          screenWidth * 0.375, 0.0, screenWidth * 0.375, 0.0),
      width: screenWidth * 0.25,
      child: new ClipRRect(
          borderRadius: new BorderRadius.circular(15.0),
          child: new Image.network(
            pickerPhoto,
            height: screenWidth * 0.25,
            fit: BoxFit.fitWidth,
          ),
      ),
    ) : polaroidPic;

    final addPhotoButton = new Padding(
      padding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
      child: new Container(
        height: 40.0,
        width: 100.0,
        child: new FlatButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          onPressed: () {
            setState(() {
              showLibCamButtons
                  ? showLibCamButtons = false
                  : showLibCamButtons = true;
            });
          },
          color: Colors.mainBlue,
          child: Text('Add Profile Picture',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final libraryCameraRow = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.fromLTRB(50.0, 0.0, 8.0, 0.0),
          child: new Container(
            height: 30.0,
            width: 120.0,
            child: new FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(7.0)),
              onPressed: () {
                _getImage(1);
              },
              color: Colors.grey,
              child: Text('Library', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0.0, 50.0, 0.0),
          child: new Container(
            height: 30.0,
            width: 120.0,
            child: new FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(7.0)),
              onPressed: () {
                _getImage(2);
              },
              color: Colors.grey,
              child: Text('Camera', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );

    final progIndicator = new Center(
      child: new SizedBox(
        height: 40.0,
        width: 40.0,
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.black105),
          value: null,
          strokeWidth: 2.0,
        ),
      ),
    );

    final continueButton = new SizedBox(
      width: double.infinity,
      height: 45.0,
      child: hideContinueButton
          ? null
          : new RaisedButton(
              onPressed: () {
                _continueAction();
              },
              textColor: Colors.white,
              color: Colors.mainPurple,
              child: new Text("Sign Up"),
            ),
    );

    return Scaffold(
      backgroundColor: Colors.offWhite,
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new ListView(
              //primary makes the page not scroll
              primary: false,
              padding: EdgeInsets.only(top: screenHeight * 0.15),
              children: <Widget>[
                userPhoto,
                SizedBox(height: 40.0),
                addPhotoButton,
                SizedBox(height: 10.0),
                showLibCamButtons ? libraryCameraRow : SizedBox(height: 10.0),
                showProgIndicator ? progIndicator : SizedBox(height: 0.0)
              ].toList(),
            ),
          ),
          continueButton
        ],
      ),
    );
  }

  _getImage(int photoChoice) async {
    setState(() {
      showProgIndicator = true;
    });

    if (photoChoice == 1) {
      await ImagePicker.pickImage(source: ImageSource.gallery)
          .then((profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic);
          setState(() {
            showLibCamButtons = false;
          });
        } else {
          setState(() {
            showProgIndicator = false;
          });
        }
      });
    } else if (photoChoice == 2) {
      await ImagePicker.pickImage(source: ImageSource.camera)
          .then((profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic);
          setState(() {
            showLibCamButtons = false;
          });
        } else {
          setState(() {
            showProgIndicator = false;
          });
        }
      });
    }
  }

  Future _uploadImageToFirebase(File profilePic) async {
    final userReference = Firestore.instance.collection("users");
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    StorageUploadTask uploadFile =
        _storage.ref().child("profile_images/${user.uid}").putFile(profilePic);

    uploadFile.onComplete.catchError((error) {
      setState(() {
        showProgIndicator = false;
        showLibCamButtons = false;
      });
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_images')
            .child(user.uid)
            .getDownloadURL();

        _savePhotoSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          "profileImageUrl": "$downloadUrl"
        };

        userReference
            .document("${user.uid}")
            .updateData(photoUrl)
            .whenComplete(() {
          print("User Photo Added");
          setState(() {
            pickerPhoto = downloadUrl;
            showProgIndicator = false;
            hideContinueButton = false;
          });
        }).catchError((e) => print(e));
      }
    });
  }

  _continueAction() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => new NavControllerState()),
            (Route<dynamic> route) => false);
  }

  _savePhotoSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("photoUrl", "$downloadUrl");
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    _uploadImageToFirebase(croppedFile);
  }

}
