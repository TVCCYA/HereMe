import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

class AddLiveChat extends StatefulWidget {
  @override
  _AddLiveChatState createState() => _AddLiveChatState();
}

class _AddLiveChatState extends State<AddLiveChat> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  final _titleFocus = FocusNode();
  final _durationFocus = FocusNode();
  String title;
  String duration;
  bool _isButtonDisabled = true;
  bool _isAnonymousChecked = false;

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  List<User> usersAround = [];
  List<String> usersAroundUid = [];

  int creationDate = DateTime.now().millisecondsSinceEpoch;
  final red = currentUser.red ?? 95;
  final green = currentUser.green ?? 71;
  final blue = currentUser.blue ?? 188;

  isValid() {
    if (title.isNotEmpty &&
        duration.isNotEmpty &&
        int.parse(duration) <= 12 &&
        int.parse(duration) > 0) {
      if (this.mounted)
        setState(() {
          _isButtonDisabled = false;
        });
    } else {
      if (this.mounted)
        setState(() {
          _isButtonDisabled = true;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    if (currentLatitude != null) getUsersAround();
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
          final hasAccountLinked = user.data['hasAccountLinked'];

          final displayedUser = User(
            uid: uid,
            hasAccountLinked: hasAccountLinked,
          );
          if (currentUser.uid != uid &&
              hasAccountLinked != null &&
              hasAccountLinked &&
              uid != adminUid) {
            if (this.mounted)
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
        key: _scaffoldKey,
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
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
            color: kColorBlack71,
            splashColor: kColorExtraLightGray,
            highlightColor: Colors.transparent,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kColorRed),
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
                              text: '${usersAround.length}' ?? 0,
                              style: kAppBarTextStyle.copyWith(
                                  color: kColorRed, fontSize: 16.0),
                            ),
                            TextSpan(
                              text: usersAround.length == 1
                                  ? ' Person Nearby'
                                  : ' People Nearby',
                              style: kAppBarTextStyle.copyWith(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextField(
                      cursorColor: kColorLightGray,
                      maxLength: 20,
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
                          color: kColorBlack71,
                          size: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      cursorColor: kColorLightGray,
                      onChanged: (value) {
                        duration = value;
                        isValid();

                        if (int.parse(value) > 12) {
                          kShowSnackbar(
                            key: _scaffoldKey,
                            text: 'Duration must be less than 12 hours',
                            backgroundColor: kColorRed,
                          );
                          if (this.mounted)
                            setState(() {
                              _isButtonDisabled = true;
                            });
                        } else if (int.parse(value) == 0) {
                          kShowSnackbar(
                            key: _scaffoldKey,
                            text: 'Duration must be greater than 0 hours',
                            backgroundColor: kColorRed,
                          );
                          if (this.mounted)
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
                          color: kColorBlack71,
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
                          activeColor: kColorRed,
                          value: _isAnonymousChecked,
                          onChanged: (value) {
                            if (this.mounted)
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
                          _isButtonDisabled ? print('disabled') : _uploadChatToFirebase();
                        },
                        splashColor: _isButtonDisabled
                            ? Colors.transparent
                            : kColorExtraLightGray,
                        highlightColor: Colors.transparent,
                        icon: Icon(
                          _isButtonDisabled
                              ? FontAwesomeIcons.arrowAltCircleUp
                              : FontAwesomeIcons.arrowAltCircleRight,
                          size: 30.0,
                          color: _isButtonDisabled
                              ? kColorLightGray
                              : kColorBlue,
                        ),
                        label: Text(
                          _isButtonDisabled ? 'Not Done' : 'Start Chat',
                          style: kDefaultTextStyle.copyWith(
                              color: _isButtonDisabled
                                  ? kColorLightGray
                                  : kColorBlue),
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
      'hostDisplayName': _isAnonymousChecked ? '' : currentUser.displayName,
      'title': title,
      'hostRed': red,
      'hostGreen': green,
      'hostBlue': blue,
      'duration': int.parse(duration),
      'endDate': creationDate + (int.parse(duration) * 3600000),
      'creationDate': creationDate,
    });
  }

  _uploadChatToFirebase() async {
    final chatId = Uuid().v4();
    final uid = currentUser.uid;
    final ref = liveChatsRef.document(uid).collection('chats').document(chatId);

    if (this.mounted)
      setState(() {
        showSpinner = true;
        _isButtonDisabled = true;
      });

    Map<String, dynamic> liveChatData = <String, dynamic>{
      'uid': currentUser.uid,
      'chatId': chatId,
      'hostDisplayName': _isAnonymousChecked ? '' : currentUser.displayName,
      'title': title,
      'hostRed': red,
      'hostGreen': green,
      'hostBlue': blue,
      'duration': int.parse(duration),
      'endDate': creationDate + (int.parse(duration) * 3600000),
      'creationDate': creationDate,
    };

    ref.setData(liveChatData).whenComplete(() {
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      setChatLocation(chatId);
      _updateInviteActivityFeed(chatId);
      Navigator.pop(context);
    }).catchError((e) {
      kShowAlert(
        context: context,
        title: 'Whoops',
        desc: 'Unable to create Live Chat at this time',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
        color: kColorRed,
      );
      if (this.mounted)
        setState(() {
          _isButtonDisabled = false;
        });
    });
  }

  _updateInviteActivityFeed(String chatId) {
    if (usersAroundUid.isNotEmpty) {
      usersAroundUid.forEach((uid) {
        DocumentReference ref =
            activityRef.document(uid).collection('feedItems').document(chatId);
        ref.setData({
          'type': 'liveChatInvite',
          'uid': currentUser.uid,
          'chatId': chatId,
          'hostDisplayName': _isAnonymousChecked ? '' : currentUser.displayName,
          'title': title,
          'hostRed': red,
          'hostGreen': green,
          'hostBlue': blue,
          'duration': int.parse(duration),
          'endDate': creationDate + (int.parse(duration) * 3600000),
          'creationDate': creationDate,
        }).whenComplete(() {
          _addInvitedToUsersInChat(chatId, uid);
        });
      });
    }
  }

  _addInvitedToUsersInChat(String chatId, String uid) {
    usersInChatRef
        .document(chatId)
        .collection('invited')
        .document(uid)
        .setData({'uid': uid});
  }
}
