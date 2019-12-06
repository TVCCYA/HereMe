import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:uuid/uuid.dart';

class AddLink extends StatefulWidget {
  final String platform;
  final Color color;
  final String icon;

  AddLink({this.platform, this.color, this.icon});

  @override
  _AddLinkState createState() => _AddLinkState(
        platform: this.platform,
        color: this.color,
        icon: this.icon,
      );
}

class _AddLinkState extends State<AddLink> {
  final String platform;
  final Color color;
  final String icon;

  _AddLinkState({this.platform, this.color, this.icon});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;
  TextEditingController _usernameController = TextEditingController();
  FocusNode _usernameName = FocusNode();
  String url;
  TextEditingController _urlController = TextEditingController();
  FocusNode _urlNode = FocusNode();
  bool _isButtonDisabled = true;

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  isValid() {
    if (platform == 'YouTube' ||
        platform == 'Facebook' ||
        platform == 'Your Website' ||
        platform == 'SoundCloud' ||
        platform == 'Pinterest') {
      if (username.isNotEmpty &&
          url.isNotEmpty &&
          !url.contains(' ') &&
          url.contains('https://')) {
        if (this.mounted) setState(() {
          _isButtonDisabled = false;
        });
      } else {
        if (this.mounted) setState(() {
          _isButtonDisabled = true;
        });
      }
    } else {
      if (username.isNotEmpty && !username.contains(' ')) {
        if (this.mounted) setState(() {
          _isButtonDisabled = false;
        });
      } else {
        if (this.mounted) setState(() {
          _isButtonDisabled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          'Link $platform',
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.35),
                color.withOpacity(0.4),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  cursorColor: kColorPurple,
                  onChanged: (value) {
                    username = value;
                    isValid();
                  },
                  focusNode: _usernameName,
                  onSubmitted: (v) {
                    if (platform == 'YouTube' ||
                        platform == 'Facebook' ||
                        platform == 'Your Website' ||
                        platform == 'SoundCloud' ||
                        platform == 'Pinterest') {
                      FocusScope.of(context).requestFocus(_urlNode);
                    } else {
                      if (username.contains(' ')) {
                        kShowSnackbar(
                            key: _scaffoldKey,
                            text: 'Username cannot contain spaces',
                            backgroundColor: kColorRed
                        );
                      }
                      _isButtonDisabled
                          ? print('disabled')
                          : _addLinkToFirebase();
                    }
                  },
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  style: kDefaultTextStyle,
                  decoration: kRegistrationInputDecoration.copyWith(
                    labelText: 'Username',
                    hintText: '$platform username',
                    hintStyle: kDefaultTextStyle.copyWith(
                      color: kColorLightGray,
                    ),
                    labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                    icon: Icon(
                      FontAwesomeIcons.at,
                      color: kColorBlack71,
                      size: 20.0,
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                platform == 'YouTube' ||
                        platform == 'Facebook' ||
                        platform == 'Your Website' ||
                        platform == 'SoundCloud' ||
                        platform == 'Pinterest'
                    ? TextField(
                        cursorColor: kColorPurple,
                        onChanged: (value) {
                          url = value;
                          isValid();
                        },
                        onSubmitted: (v) {
                          if (url.contains(' ')) {
                            kShowSnackbar(
                                key: _scaffoldKey,
                                text: 'URL cannot contain spaces',
                                backgroundColor: kColorRed
                            );
                          }
                          if (!url.contains('https://')) {
                            kShowSnackbar(
                                key: _scaffoldKey,
                                text: 'URL format: https://example.com',
                                backgroundColor: kColorRed
                            );
                          }
                          _isButtonDisabled
                              ? print('disabled')
                              : _addLinkToFirebase();
                        },
                        controller: _urlController,
                        focusNode: _urlNode,
                        autocorrect: false,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        style: kDefaultTextStyle,
                        decoration: kRegistrationInputDecoration.copyWith(
                          labelText: 'URL',
                          hintText: 'https://example.com',
                          hintStyle: kDefaultTextStyle.copyWith(
                            color: kColorLightGray,
                          ),
                          labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          icon: Image.asset(
                            icon,
                            scale: 4.75,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.topRight,
                  child: FlatButton.icon(
                    onPressed: () {
                      _isButtonDisabled
                          ? print('disabled')
                          : _addLinkToFirebase();
                      if (platform == 'YouTube' ||
                          platform == 'Facebook' ||
                          platform == 'Your Website' ||
                          platform == 'SoundCloud' ||
                          platform == 'Pinterest') {
                        if (url.contains(' ')) {
                          kShowSnackbar(
                              key: _scaffoldKey,
                              text: 'URL cannot contain spaces',
                              backgroundColor: kColorRed
                          );
                        }
                        if (!url.contains('https://')) {
                          kShowSnackbar(
                              key: _scaffoldKey,
                              text: 'URL format: https://example.com',
                              backgroundColor: kColorRed
                          );
                        }
                      } else {
                        if (username.contains(' ')) {
                          kShowSnackbar(
                              key: _scaffoldKey,
                              text: 'Username cannot contain spaces',
                              backgroundColor: kColorRed
                          );
                        }
                      }
                    },
                    splashColor:
                        _isButtonDisabled ? Colors.transparent : kColorOffWhite,
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      _isButtonDisabled
                          ? FontAwesomeIcons.arrowAltCircleUp
                          : FontAwesomeIcons.arrowAltCircleRight,
                      size: 30.0,
                      color: _isButtonDisabled ? kColorLightGray : kColorPurple,
                    ),
                    label: Text(
                      _isButtonDisabled ? 'Not Done' : 'Add Link',
                      style: kDefaultTextStyle.copyWith(
                          color: _isButtonDisabled
                              ? kColorLightGray
                              : kColorPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _determineAccount() {
    final username = _usernameController.text.trim();
    Map<String, String> retMap;

    if (platform == 'Twitter') {
      retMap = {'twitter': 'https://twitter.com/$username'};
    } else if (platform == 'Snapchat') {
      retMap = {'snapchat': 'https://www.snapchat.com/add/$username'};
    } else if (platform == 'Instagram') {
      retMap = {'instagram': 'https://www.instagram.com/$username'};
    } else if (platform == 'YouTube') {
      retMap = {'youtube': _urlController.text.trim()};
    } else if (platform == 'SoundCloud') {
      retMap = {'soundcloud': _urlController.text.trim()};
    } else if (platform == 'Venmo') {
      retMap = {'venmo': 'https://venmo.com/$username'};
    } else if (platform == 'Spotify') {
      retMap = {
        'spotify': 'https://open.spotify.com/user/${username.toLowerCase()}'
      };
    } else if (platform == 'Twitch') {
      retMap = {'twitch': 'https://www.twitch.tv/$username'};
    } else if (platform == 'Tumblr') {
      retMap = {'tumblr': 'http://$username.tumblr.com/'};
    } else if (platform == 'Reddit') {
      retMap = {'reddit': 'https://www.reddit.com/user/$username'};
    } else if (platform == 'Facebook') {
      retMap = {'facebook': _urlController.text.trim()};
    } else if (platform == 'Your Website') {
      retMap = {'your website': _urlController.text.trim()};
    } else if (platform == 'TikTok') {
      retMap = {'tiktok': 'https://www.tiktok.com/@$username'};
    } else if (platform == 'Pinterest') {
      retMap = {'pinterest': _urlController.text.trim()};
    } else {
      retMap = {'Unavailable': _urlController.text.trim()};
    }
    return retMap;
  }

  _addLinkToFirebase() async {
    String link;
    String url;
    final linkId = Uuid().v4();
    String username = _usernameController.text.trim();
    String uid = currentUser.uid;

    final ref =
        socialMediasRef.document(uid).collection('socials').document(linkId);

    _determineAccount().forEach((key, value) async {
      link = key;
      url = value;
    });

    await ref.setData(
      {
        'linkId': linkId,
        '${link}Username': username,
        'url': url,
        'creationDate': DateTime.now().millisecondsSinceEpoch,
      },
    ).whenComplete(() {
      usersRef.document(uid).updateData({
        'hasAccountLinked': true,
      });
    }).whenComplete(() {
      Navigator.pop(context, 'Successfully linked $username');
    });
  }
}
