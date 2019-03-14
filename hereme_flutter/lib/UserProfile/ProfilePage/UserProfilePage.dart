import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String username;
  String userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _getUrl();
    _getUsername();

    _loadAccounts();
//    if(linkedAccounts.length == 0) {
//      _loadAccounts();
//    }
  }

  Widget build(BuildContext context) {
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
          username == null ? '' : username,
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
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(height: 30.0),
                  userPhoto,
                  SizedBox(height: 10.0),
                  showLibCamButtons ? libraryCameraRow : SizedBox(height: 10.0),
                  showProgIndicator ? progIndicator : SizedBox(height: 0.0),
                  new ListView.builder(
                    shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: linkedAccounts.length,
                      itemBuilder: (BuildContext content, int index) {
                        Accounts account = linkedAccounts[index];
                        return accountsListTile(account, context);
                      })
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

  _getUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = await prefs.getString('photoUrl');
    setState(() {
      userPhotoUrl = url;
    });
  }

  _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = await prefs.getString('name');
    setState(() {
      username = name;
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

//  WillPopScope() {
//    setState(() {
//      linkedAccounts.removeRange(0, linkedAccounts.length);
//    });
//  }

}

void _loadAccounts() async {
  print("yeet");
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  final socialMediasReference = Firestore.instance.collection("socialMedias").document("${user.uid}").collection('socials');

  socialMediasReference.snapshots().listen((media) {
    for(int i = 0; i < media.documents.length; i++) {

//      print(media.documents[i].data.values.single.toString());
//          icon: '${_iconPath(media.documents[i].data.keys.single.toString())}');


//      if(linkedAccounts[i].icon.toString() == media.documents[i].data.keys.single.toString() || ) {
        linkedAccounts.add(
            Accounts(socialMediaHandle: media.documents[i].data.values.single.toString(),
                icon: '${_iconPath(media.documents[i].data.keys.single.toString())}')
        );
//      }
    }



    print(linkedAccounts[0].icon.toString());
    print(media.documents[0].data.keys.single.toString());
  });

}

String _iconPath(String socialmedia) {
  switch(socialmedia) {
    case 'twitterUsername': {
      return 'images/SocialMedias/twitter120.png';
    }
    break;
    case 'snapchatUsername': {
      return 'images/SocialMedias/snapLogo120.png';
    }
    break;
    case 'instagramUsername': {
      return 'images/SocialMedias/instagramAppIcon.png';
    }
    break;
    case 'youtubeUsername': {
      return 'images/SocialMedias/youtubeCircle120.png';
    }
    break;
    case 'soundcloudUsername': {
      return 'images/SocialMedias/soundcloud120.png';
    }
    break;
    case 'pinterestUsername': {
      return 'images/SocialMedias/pinterest120.png';
    }
    break;
    case 'venmoUsername': {
      return 'images/SocialMedias/venmo120.png';
    }
    break;
    case 'spotifyUsername': {
      return 'images/SocialMedias/spotify120.png';
    }
    break;
    case 'twitchUsername': {
      return 'images/SocialMedias/twitch.png';
    }
    break;
    case 'tumblrUsername': {
      return 'images/SocialMedias/tumblr120.png';
    }
    break;
    case 'redditUsername': {
      return 'images/SocialMedias/reddit120.png';
    }
    break;
    case 'facebookUsername': {
      return 'images/SocialMedias/facebook120.png';
    }
    break;
    default : {
      print("couldn't find social media username to link");
    }
  }
}

class Accounts {
  Accounts({this.socialMediaHandle, this.icon});
  final String socialMediaHandle;
  final String icon;
}

List<Accounts> linkedAccounts = [];

class accountsListTile extends ListTile {
  accountsListTile(Accounts media, context)
      : super(
      title: Text(media.socialMediaHandle, style: new TextStyle(color: Colors.offBlack, fontWeight: FontWeight.bold, fontSize: 14.0),),
      leading: new Container(
        height: 45.0,
        width: 45.0,
        child: new Image.asset(media.icon),
      ),
      onTap: () {
        print(media.socialMediaHandle);
        switch(media.socialMediaHandle){
          case 'Instagram': {
          }
          break;
        };
      },
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0)
  );
}

void refreshUserProfile() {
  setState() {

  }
}