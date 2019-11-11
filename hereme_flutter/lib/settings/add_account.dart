import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hereme_flutter/constants.dart';

final _firestore = Firestore.instance;

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  String mediaTitle;
  final usernameInput = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final urlInput = TextEditingController();
  final FocusNode urlFocus = FocusNode();
  String inputErrorText = "";
  int selectedSocialIndex = 0;
  bool showUrlTile = false;

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
    final usernameTile = new ListTile(
      contentPadding: EdgeInsets.fromLTRB(
          10.0, MediaQuery.of(context).size.height * 0.25, 0.0, 0.0),
      leading: new Container(
        width: 100.0,
        height: 25.0,
        alignment: Alignment.centerLeft,
        child: new Text(
          mediaTitle != null ? mediaTitle : "Twitter",
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: kColorOffBlack),
        ),
      ),
      trailing: new Container(
        width: MediaQuery.of(context).size.width - 115,
        height: 25.0,
        child: new TextField(
          textAlign: TextAlign.left,
          controller: usernameInput,
          focusNode: usernameFocus,
          keyboardType: TextInputType.text,
          autocorrect: false,
          textInputAction:
              showUrlTile ? TextInputAction.next : TextInputAction.go,
          style: new TextStyle(fontSize: 16.0, color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
            hintText: 'Username',
            hintStyle: new TextStyle(
                fontSize: 16.0, color: Colors.black.withOpacity(0.5)),
          ),
          onSubmitted: (_) {
            if (showUrlTile) {
              usernameFocus.unfocus();
              FocusScope.of(context).requestFocus(urlFocus);
            } else if (!_.contains(" ") && usernameInput.text.length > 0)
              _continueAction();
          },
          onChanged: (_) {
            if (_.contains(" ")) {
              setState(() {
                inputErrorText = "Your Username Cannot Contain Spaces";
              });
            } else {
              setState(() {
                inputErrorText = "";
              });
            }
          },
        ),
      ),
    );

    final urlTile = new ListTile(
      contentPadding: EdgeInsets.fromLTRB(
          10.0, MediaQuery.of(context).size.height * 0.32, 0.0, 0.0),
      leading: new Container(
        width: 100.0,
        height: 25.0,
        alignment: Alignment.centerLeft,
        child: new Text(
          "URL",
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: kColorOffBlack),
        ),
      ),
      trailing: new Container(
        width: MediaQuery.of(context).size.width - 115,
        height: 25.0,
        child: new TextField(
          textAlign: TextAlign.left,
          controller: urlInput,
          focusNode: urlFocus,
          keyboardType: TextInputType.text,
          autocorrect: false,
          textInputAction: TextInputAction.go,
          style: new TextStyle(fontSize: 16.0, color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            hintText: "$mediaTitle Account URL",
            hintStyle: new TextStyle(
                fontSize: 16.0, color: Colors.black.withOpacity(0.5)),
          ),
          onSubmitted: (_) {
            if (!_.contains(" ") &&
                !usernameInput.text.contains(" ") &&
                usernameInput.text.length > 0 &&
                urlInput.text.length > 0) _continueAction();
          },
          onChanged: (_) {
            if (_.contains(" ") || !usernameInput.text.contains(" ")) {
              setState(() {
                inputErrorText = "Your URL Cannot Contain Spaces";
              });
            } else if (usernameInput.text.contains(" ")) {
              setState(() {
                inputErrorText = "Your Username Cannot Contain Spaces";
              });
            } else {
              setState(() {
                inputErrorText = "";
              });
            }
          },
        ),
      ),
    );

    final errorText = new Container(
      padding: EdgeInsets.fromLTRB(
          0.0, MediaQuery.of(context).size.height * 0.25 - 25, 0.0, 0.0),
      alignment: Alignment.topCenter,
      child: new Text(
        inputErrorText,
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 14.0, fontStyle: FontStyle.normal, color: Colors.red),
      ),
    );

    final swipeGesture = new Container(
      margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.5 - 20.0,
          MediaQuery.of(context).size.height * 0.65,
          0.0,
          0.0),
      padding: EdgeInsets.all(0.0),
      height: 40.0,
      width: 40.0,
      child: new Image.asset('images/swipe.png'),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0.01, 0.8],
            colors: [
              _determineColor(mediaTitle).withOpacity(0.5),
              Colors.white,
            ],
          ),
        ),
        child: new GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            usernameFocus.unfocus();
            urlFocus.unfocus();
          },
          onVerticalDragDown: (_) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            usernameFocus.unfocus();
            urlFocus.unfocus();
          },
          child: new Stack(
            children: <Widget>[
//              swipeGesture,
              errorText,
              new SizedBox(
                height: 760,
                width: 460,
                child: new Center(
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(0.0, 150.0, 0.0, 0.0),
                    child: CircleListScrollView(
                      physics: CircleFixedExtentScrollPhysics(),
                      axis: Axis.horizontal,
                      itemExtent: 100,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedSocialIndex = index;
                          mediaTitle = allMedias[index].platform;
                        });
                        _determineUrl();
                      },
                      children: List.generate(allMedias.length, _buildItem),
                      radius: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                ),
              ),
//              new Container(
//                padding: EdgeInsets.fromLTRB(
//                    00.0, MediaQuery.of(context).size.height * 0.20, 0.0, 0.0),
//                alignment: Alignment.topCenter,
//                child: new Text(
//                  mediaTitle == null ? 'Twitter' : mediaTitle,
//                  style: new TextStyle(
//                      fontWeight: FontWeight.bold,
//                      fontSize: 28.0,
//                      color: Colors.offBlack),
//                ),
//              ),
              showUrlTile ? urlTile : SizedBox(),
              usernameTile
            ],
          ),
        ),
      ),
    );
  }

  _continueAction() async {
    String platform;
    String url;
    String username = usernameInput.text.trim();
    String uid = currentUser.uid;

    final ref = socialMediasRef
        .document(uid)
        .collection('socials');

    _determineAccount().forEach((key, value) async {
      platform = key;
      url = value;
    });

    await ref.add(
      {
        '${platform}Username': username,
        'url': url,
      },
    ).whenComplete(() {
      usersRef.document(uid).updateData({
        'hasAccountLinked': true,
      });
    });
    Navigator.pop(context);
  }

  Map<String, String> _determineAccount() {
    final account = allMedias[selectedSocialIndex].platform.toLowerCase();
    final username = usernameInput.text.trim();
    Map<String, String> retMap;

    if (account.contains('twitter')) {
      return retMap = {'twitter': 'https://twitter.com/$username'};
    } else if (account.contains('snapchat')) {
      return retMap = {'snapchat': 'https://www.snapchat.com/add/$username'};
    } else if (account.contains('instagram')) {
      return retMap = {'instagram': 'https://www.instagram.com/$username'};
    } else if (account.contains('youtube')) {
      return retMap = {'youtube': urlInput.text.trim()};
    } else if (account.contains('soundcloud')) {
      return retMap = {'soundcloud': urlInput.text.trim()};
    } else if (account.contains('venmo')) {
      return retMap = {'venmo': 'https://venmo.com/$username'};
    } else if (account.contains('spotify')) {
      return retMap = {
        'spotify': 'https://open.spotify.com/user/${username.toLowerCase()}'
      };
    } else if (account.contains('twitch')) {
      return retMap = {'twitch': 'https://www.twitch.tv/$username'};
    } else if (account.contains('tumblr')) {
      return retMap = {'tumblr': 'http://$username.tumblr.com/'};
    } else if (account.contains('reddit')) {
      return retMap = {'reddit': 'https://www.reddit.com/user/$username'};
    } else if (account.contains('facebook')) {
      return retMap = {'facebook': urlInput.text.trim()};
    } else {
      return retMap = {'Unavailable': urlInput.text.trim()};
    }
  }

  List<SocialMedias> allMedias = [
    SocialMedias(platform: 'Twitter', icon: 'images/SocialMedias/twitter120.png'),
    SocialMedias(
        platform: 'Snapchat', icon: 'images/SocialMedias/snapchat120.png'),
    SocialMedias(
        platform: 'Instagram', icon: 'images/SocialMedias/instagram120.png'),
    SocialMedias(platform: 'YouTube', icon: 'images/SocialMedias/youtube120.png'),
    SocialMedias(
        platform: 'SoundCloud', icon: 'images/SocialMedias/soundcloud120.png'),
    SocialMedias(platform: 'Venmo', icon: 'images/SocialMedias/venmo120.png'),
    SocialMedias(platform: 'Spotify', icon: 'images/SocialMedias/spotify120.png'),
    SocialMedias(platform: 'Twitch', icon: 'images/SocialMedias/twitch120.png'),
    SocialMedias(platform: 'Tumblr', icon: 'images/SocialMedias/tumblr120.png'),
    SocialMedias(platform: 'Reddit', icon: 'images/SocialMedias/reddit120.png'),
    SocialMedias(platform: 'Facebook', icon: 'images/SocialMedias/facebook120.png')
  ];

  void _determineUrl() {
    switch (mediaTitle) {
      case "Facebook":
        {
          showUrlTile = true;
        }
        break;
      case "YouTube":
        {
          showUrlTile = true;
        }
        break;
      case "SoundCloud":
        {
          showUrlTile = true;
        }
        break;
      default:
        {
          showUrlTile = false;
        }
    }
  }

  Color _determineColor(String media) {
    switch (media) {
      case "Twitter":
        {
          return kColorTwitterColor;
        }
        break;
      case "Snapchat":
        {
          return kColorSnapchatColor;
        }
        break;
      case "Instagram":
        {
          return kColorInstagramColor;
        }
        break;
      case "YouTube":
        {
          return kColorYoutubeColor;
        }
        break;
      case "SoundCloud":
        {
          return kColorSoundcloudColor;
        }
        break;
      case "Venmo":
        {
          return kColorVenmoColor;
        }
        break;
      case "Spotify":
        {
          return kColorSpotifyColor;
        }
        break;
      case "Twitch":
        {
          return kColorTwitchColor;
        }
        break;
      case "Tumblr":
        {
          return kColorTumblrColor;
        }
        break;
      case "Reddit":
        {
          return kColorRedditColor;
        }
        break;
      case "Facebook":
        {
          return kColorFacebookColor;
        }
        break;
      default:
        {
          return kColorOffBlack;
        }
    }
  }
}

String randomAutoId() {
  String autoId = '-L';
  var rng = new Random();

  for (var i = 0; i < 2; i++) {
    autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}';
    autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}';
  }

  for (var i = 0; i < 14; i++) {
    int rngSelect = rng.nextInt(21);
    if (rngSelect == 0 || rngSelect == 21) {
      rngSelect == 0
          ? autoId += '${String.fromCharCode(45)}'
          : autoId += '${String.fromCharCode(95)}';
    } else if (rngSelect > 11) {
      rngSelect > 6
          ? autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}'
          : autoId += '${String.fromCharCode(rng.nextInt(26) + 97)}';
    } else {
      rngSelect > 16
          ? autoId += '${String.fromCharCode(rng.nextInt(26) + 65)}'
          : autoId += '${String.fromCharCode(rng.nextInt(26) + 97)}';
    }
  }

  return autoId;
}


class SocialMedias {
  final String platform;
  final String icon;
  final Color color;
  SocialMedias({this.platform, this.icon, this.color});
}