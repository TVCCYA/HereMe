import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hereme_flutter/SettingsMenu/MenuListPage.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool showUserPhoto = false;
  bool showLibCamButtons = false;
  bool showProgIndicator = false;
  File pickerPhoto;
  String userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _getUid();
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final polaroidPic = new Container(
      child: new ImageIcon(new AssetImage("images/polaroidProPic180.png"),
          size: screenWidth * 0.25, color: Colors.black),
    );

    final userPhoto = userPhotoUrl != null
        ? new Container(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.36, 0.0, screenWidth * 0.36, 0.0),
//      width: screenWidth * 0.25,
            child: new ClipRRect(
                borderRadius: new BorderRadius.circular(15.0),
                child: GestureDetector(
                    onTap: _changeUserPhoto,
                    child: new Image.network(
                      userPhotoUrl,
                      height: screenWidth * 0.28,
//             width: screenWidth * 0.25,
                      fit: BoxFit.cover,
                    ))),
          )
        : polaroidPic;

    final libraryCameraRow = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.fromLTRB(50.0, 0.0, 8.0, 0.0),
          child: new Container(
            height: 40.0,
            width: 120.0,
            child: new FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0)),
              onPressed: () {
                _getImage(1);
              },
              color: Colors.mainPurple,
              child: Text('Library', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0.0, 50.0, 0.0),
          child: new Container(
            height: 40.0,
            width: 120.0,
            child: new FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0)),
              onPressed: () {
                _getImage(2);
              },
              color: Colors.mainPurple,
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

    return Scaffold(
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: new Text(
          "Name",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(icon: new Image.asset("images/menu55.png", color: Colors.black), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => new ListPage()),
            );
    })
        ],
      ),
      body: new GestureDetector(
        onTap: () {
          setState(() {
            showLibCamButtons = false;
          });
        },
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              child: new ListView(
                padding: EdgeInsets.only(top: 5.0),
                children: <Widget>[
                  SizedBox(height: 30.0),
                  userPhoto,
                  SizedBox(height: 10.0),
                  showLibCamButtons ? libraryCameraRow : SizedBox(height: 10.0),
                  showProgIndicator ? progIndicator : SizedBox(height: 0.0)
                ].toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getImage(int photoChoice) async {
    if (photoChoice == 1) {
      await ImagePicker.pickImage(source: ImageSource.gallery)
          .then((profilePic) {
        if (profilePic != null) {
          pickerPhoto = profilePic;
          showLibCamButtons = false;
          _uploadImageToFirebase(profilePic);
        }
      });
    } else if (photoChoice == 2) {
      await ImagePicker.pickImage(source: ImageSource.camera)
          .then((profilePic) {
        if (profilePic != null) {
          pickerPhoto = profilePic;
          showLibCamButtons = false;
          _uploadImageToFirebase(profilePic);
        }
      });
    }
  }

  Future _uploadImageToFirebase(File profilePic) async {
    final userReference = Firestore.instance.collection("users");
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    setState(() {
      showProgIndicator = true;
    });

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    StorageUploadTask uploadFile =
        _storage.ref().child("profile_images/${user.uid}").putFile(profilePic);

    uploadFile.onComplete.catchError((error) {
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
            showProgIndicator = false;
            showUserPhoto = true;
          });
        }).catchError((e) => print(e));
      }
    });
  }

  _savePhotoSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("photoUrl", "$downloadUrl");
  }

  _getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = await prefs.getString('photoUrl');
    setState(() {
      userPhotoUrl = url;
    });
  }

  void _changeUserPhoto() {
    setState(() {
      showLibCamButtons ? showLibCamButtons = false : showLibCamButtons = true;
    });

//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type AlertDialog
//        return AlertDialog(
//          title: new Text("Change Your Photo"),
////          content: new Text("Creates an alert dialog.Typically used in conjunction with showDialog."+
////              "The contentPadding must not be null. The titlePadding defaults to null, which implies a default."),
//
//          actions: <Widget>[
//            // usually buttons at the bottom of the dialog
//            new FlatButton(
//              child: new Text("Library"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//            new FlatButton(
//              child: new Text("Camera"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//            new FlatButton(
//              child: new Text("Cancel"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
  }
}
