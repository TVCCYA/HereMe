import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

class AddLiveChat extends StatefulWidget {
  @override
  _AddLiveChatState createState() => _AddLiveChatState();
}

class _AddLiveChatState extends State<AddLiveChat> {
  bool showSpinner = false;
  final _titleFocus = FocusNode();
  final _durationFocus = FocusNode();
  String title;
  String duration;
  bool _isButtonDisabled = true;
  bool _isAnonymousChecked = false;

  List<User> usersAround = [];
  List<String> usersAroundUid = [];

  isValid() {
    if (title.isNotEmpty &&
        duration.isNotEmpty &&
        int.parse(duration) <= 12 &&
        int.parse(duration) > 0) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  isLoading() {
    // if location values are loading -> showSpinner = true
    // else location values have loaded completely showSpinner = false
  }

  @override
  void initState() {
    super.initState();
    getUsersAround();
  }

  getUsersAround() {
    Geoflutterfire geo = Geoflutterfire();
    Query collectionRef = userLocationsRef;
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionRef).within(
              center: geo.point(
                  latitude: currentLatitude, longitude: currentLongitude),
              radius: 0.4,
              field: 'position',
              strictMode: true,
            );

    stream.listen((snapshot) {
      if (snapshot == null) {
        showSpinner = true;
      } else {
        List<DocumentSnapshot> users = [];
        for (var data in snapshot) {
          users.add(data);
        }
        for (var user in users) {
          final uid = user.data['uid'];
          final displayedUser = User(
            uid: uid,
          );
          if (currentUser.uid != uid) {
            setState(() {
              usersAround.add(displayedUser);
              usersAroundUid.add(displayedUser.uid);
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2.0,
          title: Text(
            'Create Live Chat',
            style: kAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft),
            onPressed: () {
              Navigator.pop(context);
            },
            color: kColorBlack105,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kColorPurple),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (_) {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${usersAround.length}',
                              style: kAppBarTextStyle.copyWith(
                                  color: kColorPurple, fontSize: 16.0),
                            ),
                            TextSpan(
                              text: ' People Around You',
                              style: kAppBarTextStyle.copyWith(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextField(
                      cursorColor: kColorPurple,
                      onChanged: (value) {
                        title = value;
                        isValid();
                      },
                      focusNode: _titleFocus,
                      onSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_durationFocus);
                      },
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      style: kDefaultTextStyle,
                      decoration: kRegistrationInputDecoration.copyWith(
                        labelText: 'Title',
                        hintText: 'Name Your Chat',
                        hintStyle: kDefaultTextStyle.copyWith(
                          color: kColorLightGray,
                        ),
                        labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        icon: Icon(
                          FontAwesomeIcons.penFancy,
                          color: kColorBlack105,
                          size: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      cursorColor: kColorPurple,
                      onChanged: (value) {
                        duration = value;
                        isValid();

                        if (int.parse(value) > 12) {
                          kErrorFlushbar(
                              context: context,
                              errorText: 'Duration must be less than 12 hours');
                          setState(() {
                            _isButtonDisabled = true;
                          });
                        } else if (int.parse(value) == 0) {
                          kErrorFlushbar(
                              context: context,
                              errorText:
                                  'Duration must be greater than 0 hours');
                          setState(() {
                            _isButtonDisabled = true;
                          });
                        }
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      focusNode: _durationFocus,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      style: kDefaultTextStyle,
                      decoration: kRegistrationInputDecoration.copyWith(
                        labelText: 'Duration of Chat',
                        hintText: '# of Hours',
                        hintStyle: kDefaultTextStyle.copyWith(
                          color: kColorLightGray,
                        ),
                        labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        icon: Icon(
                          FontAwesomeIcons.hourglassHalf,
                          color: kColorBlack105,
                          size: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      children: <Widget>[
                        Text(
                          'Host Anonymously?',
                          style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        ),
                        Checkbox(
                          activeColor: kColorPurple,
                          value: _isAnonymousChecked,
                          onChanged: (value) {
                            setState(() {
                              _isAnonymousChecked = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: FlatButton.icon(
                        onPressed: () {
                            _isButtonDisabled
                            ? print('disabled')
                            : _uploadChatToFirebase();
                        },
                        splashColor: _isButtonDisabled
                            ? Colors.transparent
                            : kColorOffWhite,
                        highlightColor: Colors.transparent,
                        icon: Icon(
                          _isButtonDisabled
                              ? FontAwesomeIcons.arrowAltCircleUp
                              : FontAwesomeIcons.arrowAltCircleRight,
                          size: 30.0,
                          color: _isButtonDisabled
                              ? kColorLightGray
                              : kColorPurple,
                        ),
                        label: Text(
                          _isButtonDisabled ? 'Not Done' : 'Start Chat',
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
        ),
      ),
    );
  }

  setChatLocation(String chatId) async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint myLocation =
        geo.point(latitude: currentLatitude, longitude: currentLongitude);
    await liveChatLocationsRef.document(chatId).setData({
      'position': myLocation.data,
      'uid': currentUser.uid,
      'chatId': chatId,
      'creationDate': DateTime.now().millisecondsSinceEpoch * 1000,
      'title': title,
    });
  }

  _uploadChatToFirebase() async {
    final chatId = Uuid().v4();
    final uid = currentUser.uid;
    final ref = liveChatsRef.document(uid).collection('chats').document(chatId);

    Map<String, dynamic> liveChatData = <String, dynamic> {
      'title': title,
      'chatId': chatId,
      'hostUsername': _isAnonymousChecked ? '': currentUser.username,
      'duration': duration,
      'uid': currentUser.uid,
      'invites': usersAroundUid,
      'creationDate': DateTime.now().millisecondsSinceEpoch * 1000,
    };

    ref.setData(liveChatData).whenComplete(() {
      setChatLocation(chatId);
      Navigator.pop(context);
    }).catchError((e) =>
        kErrorFlushbar(context: context, errorText: 'Unable to create Live Chat at this time'));
  }
}
