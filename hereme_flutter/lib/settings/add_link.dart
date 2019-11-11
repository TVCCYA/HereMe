import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
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

  String username;
  TextEditingController _usernameController = TextEditingController();
  FocusNode _usernameName = FocusNode();
  String url;
  TextEditingController _urlController = TextEditingController();
  FocusNode _urlNode = FocusNode();
  bool _isButtonDisabled = true;

  isValid() {
    if (platform == 'YouTube' ||
        platform == 'Facebook' ||
        platform == 'Your Website' ||
        platform == 'SoundCloud') {
      if (username.isNotEmpty &&
          !username.contains(' ') &&
          url.isNotEmpty &&
          !url.contains(' ') &&
          url.contains('https://')) {
        setState(() {
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
          _isButtonDisabled = true;
        });
      }
    } else {
      if (username.isNotEmpty && !username.contains(' ')) {
        setState(() {
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
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
      appBar: AppBar(
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
                    if (username.contains(' ')) {
                      kErrorFlushbar(
                          context: context,
                          errorText: 'Username cannot contain spaces');
                    } else {
                      if (platform == 'YouTube' ||
                          platform == 'Facebook' ||
                          platform == 'Your Website' ||
                          platform == 'SoundCloud') {
                        FocusScope.of(context).requestFocus(_urlNode);
                      } else {
                        _isButtonDisabled
                            ? print('disabled')
                            : _addLinkToFirebase();
                      }
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
                        platform == 'SoundCloud'
                    ? TextField(
                        cursorColor: kColorPurple,
                        onChanged: (value) {
                          url = value;
                          isValid();
                        },
                        onSubmitted: (v) {
                          if (url.contains(' ')) {
                            kErrorFlushbar(
                                context: context,
                                errorText: 'URL cannot contain spaces');
                          }
                          if (!url.contains('https://')) {
                            kErrorFlushbar(
                                context: context,
                                errorText: 'URL format: https://example.com');
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
                          platform == 'SoundCloud') {
                        if (username.contains(' ')) {
                          kErrorFlushbar(
                              context: context,
                              errorText: 'Username cannot contain spaces');
                        }
                        if (url.contains(' ')) {
                          kErrorFlushbar(
                              context: context,
                              errorText: 'URL cannot contain spaces');
                        }
                        if (!url.contains('https://')) {
                          kErrorFlushbar(
                              context: context,
                              errorText: 'URL format: https://example.com');
                        }
                      } else {
                        if (username.contains(' ')) {
                          kErrorFlushbar(
                              context: context,
                              errorText: 'Username cannot contain spaces');
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
    print(link);
    print(url);

    await ref.setData(
      {
        'linkId': linkId,
        '${link}Username': username,
        'url': url,
      },
    ).whenComplete(() {
      usersRef.document(uid).updateData({
        'hasAccountLinked': true,
      });
    }).whenComplete(() {
      Navigator.pop(context);
      kShowFlushBar(
          text: 'Successfully linked account',
          icon: FontAwesomeIcons.exclamation,
          color: color,
          context: context
      );
    });
  }
}
