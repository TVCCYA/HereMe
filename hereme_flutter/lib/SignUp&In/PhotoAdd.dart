import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class PhotoAdd extends StatefulWidget {
  final String uid;

  PhotoAdd({Key key, this.uid}) : super(key: key);

  @override
  _PhotoAddState createState() => _PhotoAddState();
}

class _PhotoAddState extends State<PhotoAdd> {
  @override
  Widget build(BuildContext context) {
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
//            _signInWithEmail();
          },
          color: Colors.mainBlue,
          child: Text('Add Profile Picture',
              style: TextStyle(color: Colors.white)),
        ),
      ),
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
              padding: EdgeInsets.only(top: 100.0),
              children: <Widget>[
                polaroidPic,
                SizedBox(height: 50.0),
                addPhotoButton
              ].toList(),
            ),
          ),
        ],
      ),
    );
  }
}
