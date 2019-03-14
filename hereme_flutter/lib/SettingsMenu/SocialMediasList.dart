import 'package:flutter/material.dart';
import 'package:circle_wheel_scroll/circle_wheel_render.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UserProfile/ProfilePage/UserProfilePage.dart';


class SocialMedias {
  SocialMedias({this.media, this.icon});
  final String media;
  final String icon;
}

class MediasList extends StatefulWidget {
  @override
  _MediasListState createState() => _MediasListState();
}

class _MediasListState extends State<MediasList> {
  String mediaTitle;
  final usernameInput = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  String inputErrorText = "";
  int selectedSocialIndex = 0;

  Widget _buildItem(int i) {
    SocialMedias media = allMedias[i];
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 100,
          padding: EdgeInsets.all(20),
//          color: Colors.blue[100 * ((i % 8) + 1)],
          child: Image.asset(media.icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final errorText = new Container(
      alignment: Alignment.topCenter,
      child: new Text(
        inputErrorText,
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 14.0,
            fontStyle: FontStyle.normal,
            color: Colors.red
        ),
      ),
    );

    final swipeGesture = new Container(
      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.5 - 20.0, MediaQuery.of(context).size.height * 0.65, 0.0, 0.0),
      padding: EdgeInsets.all(0.0),
      height: 40.0,
        width: 40.0,
        child: new Image.asset('images/swipe.png'),
    );

    final usernameField = new Container(
      padding: EdgeInsets.fromLTRB(50.0, MediaQuery.of(context).size.height * 0.25 + 40, 50.0, 0.0),
      alignment: Alignment.topCenter,
      child: new TextField(
        textAlign: TextAlign.center,
        controller: usernameInput,
        focusNode: usernameFocus,
        keyboardType: TextInputType.text,
        autocorrect: false,
        textInputAction: TextInputAction.go,
        style: new TextStyle(fontSize: 16.0, color: Colors.black),
        decoration: InputDecoration(
//                  border: InputBorder.none,
//              contentPadding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
          hintText: 'Username',
          hintStyle: new TextStyle(fontSize: 20.0, color: Colors.black),
        ),
            //todo make contunueAction but rename it
        onSubmitted: (_){
          _continueAction();
        },
      ),
    );

    return Scaffold(
      body: new GestureDetector(
        onTap: () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      usernameFocus.unfocus();
    },
        onVerticalDragDown: (_){
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          usernameFocus.unfocus();
        },
        child: new Stack(
        children: <Widget>[
          swipeGesture,
          errorText == "" ? SizedBox(height: 0.0) : errorText,
          new SizedBox(
            height: 760,
            width: 460,
            child: new Center(
              child: new Container(
                padding: EdgeInsets.fromLTRB(0.0, 150.0, 0.0, 0.0),
                // height: 260,
                // width: 160,
                child: CircleListScrollView(
                  physics: CircleFixedExtentScrollPhysics(),
                  axis: Axis.horizontal,
                  itemExtent: 100,
                  onSelectedItemChanged: (index){
                    setState(() {
                      selectedSocialIndex = index;
                      mediaTitle = allMedias[index].media;
                    });
                  },
                  children: List.generate(allMedias.length, _buildItem),
                  radius: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(00.0, MediaQuery.of(context).size.height * 0.20, 0.0, 0.0),
            alignment: Alignment.topCenter,
            child: new Text(
              mediaTitle == null ? 'Twitter' : mediaTitle,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.0,
                  color: Colors.offBlack),
            ),
            ),
          usernameField,
        ],
      ),
      ),
    );
  }

  _continueAction() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userReference = Firestore.instance.collection("users").document("${user.uid}");
    final socialMediasReference = Firestore.instance.collection("socialMedias").document("${user.uid}").collection('socials').document(_randomAutoId());
    String socialUsername = allMedias[selectedSocialIndex].media.toLowerCase() + 'Username';

    Firestore.instance.collection('users').document(user.uid).get().then((userInstance) {

      print(userInstance.data["numberOfSocialMedias"]);

      if(userInstance.data["numberOfSocialMedias"] == null) {
        Map<String, int> numberOfMediaData = <String, int>{
          "numberOfSocialMedias" : 1,
        };
        userReference.updateData(numberOfMediaData).catchError((e) => print(e)).then((_) => print("number of social medias node created"));
      } else {
        int incrementedNum = userInstance.data["numberOfSocialMedias"] + 1;
        Map<String, int> numberOfMediaData = <String, int>{
          "numberOfSocialMedias" : incrementedNum,
        };
        userReference.updateData(numberOfMediaData).catchError((e) => print(e)).then((_) => print("number of social medias incremented"));
      }
    });

    Map<String, String> socialMediaData = <String, String>{
    "${socialUsername}" : usernameInput.text,
    };

    socialMediasReference.updateData(socialMediaData).whenComplete(() {
      print("Social Media Updated");

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfile()),
      );

    }).catchError((e){
      print(e.toString());
      String error = e.toString();
      if(error.contains('No document to update')) {
        socialMediasReference.setData(socialMediaData).whenComplete(() {
          print("social Media Set");

        }).catchError((e) => print(e));
      }
    });
  }

  List<SocialMedias> allMedias = [
    SocialMedias(media: 'Twitter', icon: 'images/SocialMedias/twitter120.png'),
    SocialMedias(media: 'Snapchat', icon: 'images/SocialMedias/snapLogo120.png'),
    SocialMedias(media: 'Instagram', icon: 'images/SocialMedias/instagramAppIcon.png'),
    SocialMedias(media: 'YouTube', icon: 'images/SocialMedias/youtubeCircle120.png'),
    SocialMedias(media: 'SoundCloud', icon: 'images/SocialMedias/soundcloud120.png'),
    SocialMedias(media: 'Pinterest', icon: 'images/SocialMedias/pinterest120.png'),
    SocialMedias(media: 'Venmo', icon: 'images/SocialMedias/venmo120.png'),
    SocialMedias(media: 'Spotify', icon: 'images/SocialMedias/spotify120.png'),
    SocialMedias(media: 'Twitch', icon: 'images/SocialMedias/twitch.png'),
    SocialMedias(media: 'Tumblr', icon: 'images/SocialMedias/tumblr120.png'),
    SocialMedias(media: 'Reddit', icon: 'images/SocialMedias/reddit120.png'),
    SocialMedias(media: 'Facebook', icon: 'images/SocialMedias/facebook120.png')
  ];

}

String _randomAutoId() {
  String autoId = '-L';
  var rng = new Random();

  for(var i = 0; i < 2; i++) {
    autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}';
    autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}';
  }

  for(var i = 0; i < 14; i++) {
    int rngSelect = rng.nextInt(21);
    if(rngSelect == 0 || rngSelect == 21){
      rngSelect == 0 ? autoId += '${String.fromCharCode(45)}' :
      autoId += '${String.fromCharCode(95)}';
    } else if(rngSelect > 11) {
      rngSelect > 6 ? autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}' :
      autoId += '${String.fromCharCode(rng.nextInt(26) + 97)}';
    } else {
      rngSelect > 16 ? autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}' :
      autoId += '${String.fromCharCode(rng.nextInt(26) + 97)}';
    }
  }

  return autoId;
}

//class SocialMediaListTile extends ListTile {
//  SocialMediaListTile(SocialMedias option, context)
//      : super(
//      title: Text(option.media, style: new TextStyle(color: Colors.offBlack, fontWeight: FontWeight.bold, fontSize: 14.0),),
//      leading: new Container(
//        height: 45.0,
//        width: 45.0,
//        child: new Image.asset(option.icon),
//      ),
//      onTap: () {
//        print(option.media);
//        switch(option.media){
//          case 'Link Your Accounts': {
//
//          }
//          break;
//          case 'Saved Them': {
//
//          }
//          break;
////        case 'My Local Photos': {
////
////        }
////        break;
//          case 'HideMe': {
//
//          }
//          break;
//          case 'Tell Your Friends': {
//
//          }
//          break;
//          case 'Rate HereMe': {
//
//          }
//          break;
//          case 'Help & Support': {
//
//          }
//          break;
//          case 'Logout': {
//
//          }
//          break;
//        };
//      },
//      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0)
//  );
//}
