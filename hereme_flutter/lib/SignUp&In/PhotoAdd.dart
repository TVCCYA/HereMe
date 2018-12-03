import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
//import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoAdd extends StatefulWidget {
  final String uid;

  PhotoAdd({Key key, this.uid}) : super(key: key);

  @override
  _PhotoAddState createState() => _PhotoAddState();
}

class _PhotoAddState extends State<PhotoAdd> {
  bool showLibCamButtons = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    final polaroidPic = new ImageIcon(
        new AssetImage("images/polaroidProPic180.png"),
        size: 120.0,
        color: Colors.black);

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
              showLibCamButtons ? showLibCamButtons = false : showLibCamButtons = true;
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

    return Scaffold(
      backgroundColor: Colors.offWhite,
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new ListView(
              //primary makes the page not scroll
              primary: false,
              padding: EdgeInsets.only(top: screenHeight * 0.15),
              children: <Widget>[
                polaroidPic,
                SizedBox(height: 50.0),
                addPhotoButton,
                SizedBox(height: 10.0),
                showLibCamButtons ? libraryCameraRow : SizedBox(height: 0.0)
              ].toList(),
            ),
          ),
        ],
      ),
    );
  }

  _getImage(int photoChoice) async {
    if(photoChoice == 1) {
      File profilePic = await ImagePicker.pickImage(source: ImageSource.gallery);
      _uploadImageToFirebase(profilePic);
    } else if(photoChoice == 2) {
      File profilePic = await ImagePicker.pickImage(source: ImageSource.camera);
      _uploadImageToFirebase(profilePic);
    }
  }

  Future _uploadImageToFirebase(File profilePic) async {
    final userReference = Firestore.instance.collection("users");
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    StorageUploadTask uploadFile = _storage.ref().child("profile_images/${user.uid}").putFile(profilePic);

    uploadFile.onComplete.catchError((error){
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if(succeed == true) {
        final downloadUrl = await _storage.ref().child('profile_images').child(user.uid).getDownloadURL();

        

        Map<String, String> seflieUrl = <String, String>{
          "profileImageUrl" : "$downloadUrl"
        };

        userReference.document("${user.uid}").updateData(seflieUrl).whenComplete(() {
          print("User Photo Added");
        }).catchError((e) => print(e));
      }
    });
  }

}
