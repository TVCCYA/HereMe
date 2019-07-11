import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/TabController.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hereme_flutter/SettingsMenu/MenuListPage.dart';
import 'package:hereme_flutter/GridFind/GridFindCollectionPage.dart';
import 'package:hereme_flutter/UserProfile/ProfilePage/Accounts&iconPath.dart';


class UserProfile extends StatefulWidget {
  final Profiles passedProfile;
  UserProfile({Key key, this.passedProfile}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with AutomaticKeepAliveClientMixin{
  bool clientSideUser = true;
  bool showLibCamButtons = false;
  bool showProgIndicator = false;
  String username;
  String userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _determinePage();
  }

  @override
  bool get wantKeepAlive => true;
//  bool get wantKeepAlive => keepProfileAlive == null ? false : keepProfileAlive;

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final placeholderProfile = new Container(
        height: screenWidth * 0.25,
        width: screenWidth * 0.25,
        decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 25.0,
              spreadRadius: 25.0,
              offset: Offset(
                15.0,
                15.0,
              ),
            )
          ],
        ));

    final userPhoto = userPhotoUrl != null
        ? new Card(
            margin: EdgeInsets.fromLTRB(
                screenWidth * 0.36, 0.0, screenWidth * 0.36, 0.0),
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: new InkResponse(
                child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(15.0),
                    child: new CachedNetworkImage(
                      imageUrl: userPhotoUrl,
                      height: screenWidth * 0.28,
                      fit: BoxFit.cover,
                    )),
                onTap: () => _changeUserPhoto(),
            ),
          )
        : placeholderProfile;

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

    final scaffold = new Scaffold(
      appBar: new AppBar(
         leading: clientSideUser ? SizedBox() : new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: (){Navigator.pop(context);},
          color: Colors.mainPurple,
        ),
//        elevation: 5.0,
        brightness: Brightness.light,
        backgroundColor: Colors.offWhite,
        title: new Text(
          username == null ? '' : username,
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
              icon: new Image.asset("images/menu55.png",
                  color: Colors.black),
              onPressed: () {
                if (clientSideUser) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new ListPage()),
                  );
                }
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
                  showLibCamButtons
                      ? libraryCameraRow
                      : SizedBox(height: 10.0),
                  showProgIndicator
                      ? progIndicator
                      : SizedBox(height: 0.0),
                  new ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: linkedAccounts.length,
                      itemBuilder: (BuildContext content, int index) {
                        return _buildAccountTiles(linkedAccounts[index]);
                      })
                ].toList(),
              ),
            ),
          ],
        ),
      ),
    );

    return new WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: !clientSideUser ? new SwipeDetector(
          onSwipeRight: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: scaffold,
        ) : scaffold
    );
  }

  ListTile _buildAccountTiles(Accounts media) {
    return new ListTile(
        title: Text(
          media.socialMediaHandle,
          style: new TextStyle(
              color: Colors.offBlack,
              fontWeight: FontWeight.bold,
              fontSize: 14.0),
        ),
        leading: new Container(
          height: 45.0,
          width: 45.0,
          child: new Image.asset(media.icon),
        ),
        onTap: () {
          _actionSheet(context, media);
        },
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0)
    );
  }

  void _actionSheet(context, Accounts media) {
    showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
      return Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                title: new Text(
                    'Open In App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    )
                ),
                onTap: () {
                  launchUrl(media);
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                title: new Text(
                    'Copy To Clipboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    )
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: media.socialMediaHandle));
                  Navigator.pop(context);
                },
              ),
              clientSideUser ? new ListTile(
                title: new Text(
                    'Unlink ${media.socialMediaHandle}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    )
                ),
                onTap: () {
                  _handleUnlink(context, media);
                  Navigator.pop(context);
                },
              ) : SizedBox(),
              new ListTile(
                title: new Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    )
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  //todo decrement numberOfSocialmedias in firebase
  void _handleUnlink(context, Accounts media) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = await prefs.getString('uid');

    final socialMediasReference = Firestore.instance
        .collection("socialMedias")
        .document(uid)
        .collection('socials');

    socialMediasReference.snapshots().listen((snapshot) {

      for (int i = 0; i < snapshot.documents.length; i++) {

        if(snapshot.documents[i].data.values.first.toString() == media.socialMediaHandle) {
          socialMediasReference.document(snapshot.documents[i].documentID.toString()).delete();
          _loadAccounts(uid);
        }
      }
    });
  }

  void _changeUserPhoto() {
    if (clientSideUser) {
      setState(() {
        showLibCamButtons
            ? showLibCamButtons = false
            : showLibCamButtons = true;
      });
    }
  }

  void _determinePage() {
    if (widget.passedProfile == null) {
      setState(() {
        clientSideUser = true;
      });
      _getSharedPrefs();
    } else {
      final String userUid = widget.passedProfile.uid;
      setState(() {
        clientSideUser = false;
        username = widget.passedProfile.username;
        userPhotoUrl = widget.passedProfile.profileImageUrl;
      });
      _loadAccounts(userUid);
    }
  }

  _savePhotoSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("photoUrl", "$downloadUrl");
  }

  _getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = await prefs.getString('photoUrl');
    String name = await prefs.getString('name');
    String uid = await prefs.getString('uid');
    setState(() {
      userPhotoUrl = url;
      username = name;
    });
    _loadAccounts(uid);
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

  Future _uploadImageToFirebase(File profilePic) async {
    final userReference = Firestore.instance.collection("users");
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    StorageUploadTask uploadFile =
    _storage.ref().child("profile_images/${user.uid}").putFile(profilePic);

    uploadFile.onComplete.catchError((error) {
      print(error);
      setState(() {
        showProgIndicator = false;
        showLibCamButtons = false;
      });
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
            userPhotoUrl = downloadUrl;
            showProgIndicator = false;
          });
        }).catchError((e) => print(e));
      }
    });
  }

  void _loadAccounts(String userUid) async {
    linkedAccounts.clear();

    final socialMediasReference = Firestore.instance
        .collection("socialMedias")
        .document(userUid)
        .collection('socials');

    socialMediasReference.snapshots().listen((snapshot) {
      for (int i = 0; i < snapshot.documents.length; i++) {
        bool contains = false;

        /// removes duplicates when an account gets deleted
        for (int y = 0; y < linkedAccounts.length; y++) {
          if(snapshot.documents[i].data.values.first.toString() == linkedAccounts[y].socialMediaHandle.toString()) {
            String socialMedia = snapshot.documents[i].data.keys.first.toString().replaceAll("Username", "");
            for(int z = 0; z < linkedAccounts.length; z++) {
              if(linkedAccounts[z].icon.toString().contains(socialMedia)) {
                contains = true;
              }
            }
          }
        }

        if(contains == false) {

          if(mounted) {
            if(snapshot.documents[i].data.values.length == 1) {
              setState(() {
                linkedAccounts.add(Accounts(
                    socialMediaHandle: snapshot.documents[i].data.values.single.toString(),
                    icon: iconPath(snapshot.documents[i].data.keys.single.toString())
                )
                );
              });
            } else {
              setState(() {
                linkedAccounts.add(Accounts(
                    socialMediaHandle: snapshot.documents[i].data.values.first.toString(),
                    icon: iconPath(snapshot.documents[i].data.keys.first.toString()),
                    socialMediaUrl: snapshot.documents[i].data.values.last.toString())
                );
              });
            }
          } else print("ERROR: not mounted");
        }
        }
    });
    for(int i = 0; i < linkedAccounts.length; i++){
      print("linked accounts: ${linkedAccounts[i].toString()}");
    }
    setState(() {
      keepProfileAlive = true;
    });
  }

}

void launchUrl(Accounts media) async {
  String url = determineUrl(media);


  print(url);

  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false);
  } else {
    await launch(url, forceSafariVC: true);
  }
}

String determineUrl(Accounts media) {
  final icon = media.icon;
  final socialMed = media.socialMediaHandle;
  final socialMedUrl = media.socialMediaUrl;

  if(icon.contains("twitter")) {
    return "https://twitter.com/$socialMed";
  } else if (icon.contains("snapchat")) {
    return "https://www.snapchat.com/add/$socialMed";
  } else if (icon.contains("instagram")) {
    return "https://www.instagram.com/$socialMed";
  } else if (icon.contains("youtube")) {
    return socialMedUrl;
  } else if (icon.contains("soundcloud")) {
    return socialMedUrl;
  } else if (icon.contains("venmo")) {
    return "https://venmo.com/$socialMed";
  } else if (icon.contains("spotify")) {
    return "https://open.spotify.com/user/${socialMed.toLowerCase()}";
  } else if (icon.contains("twitch")) {
    return "https://www.twitch.tv/$socialMed";
  } else if (icon.contains("tumblr")) {
    return "http://$socialMed.tumblr.com/";
  } else if (icon.contains("reddit")) {
    return "https://www.reddit.com/user/$socialMed";
  } else if (icon.contains("facebook")) {
    return socialMedUrl;
  } else {
    print("whoops, no media found");
  }
}