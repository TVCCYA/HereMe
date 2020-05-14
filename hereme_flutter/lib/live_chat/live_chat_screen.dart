import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:animator/animator.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:uuid/uuid.dart';

String chatIdentifier;
final reportedLiveChatsRef = Firestore.instance.collection('reportedLiveChats');

class LiveChatScreen extends StatefulWidget {
  final String chatId;
  final String city;

  LiveChatScreen({
    this.chatId,
    this.city,
  });

  @override
  _LiveChatScreenState createState() => _LiveChatScreenState(
        chatId: this.chatId,
        city: this.city
      );
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final String chatId;
  final String city;

  _LiveChatScreenState({
    this.chatId,
    this.city
  });

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController liveChatController = TextEditingController();
  String message;
  bool _hasStartedTyping = false;
  List<dynamic> uidsInChat = [];
  int inChatCount = 0;
  int now = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    streamUserCountInChat();
    if (this.mounted) setState(() {
      chatIdentifier = chatId;
    });
  }
  
  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  startedTyping() {
    if (message.isNotEmpty) {
      if (this.mounted) setState(() {
        _hasStartedTyping = true;
      });
      if (message.length > 200) {
        if (this.mounted) setState(() {
          _hasStartedTyping = false;
        });
      }
    } else {
      if (this.mounted) setState(() {
        _hasStartedTyping = false;
      });
    }
  }

  List<LiveChatMessage> allMessages = [];
  buildMessages() {
    return StreamBuilder(
      stream: liveChatMessagesRef
          .document(chatId)
          .collection('messages')
          .orderBy('creationDate', descending: true)
          .limit(100)
//          .where('creationDate', isGreaterThanOrEqualTo: date)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<LiveChatMessage> messages = [];
        snapshot.data.documents.forEach((doc) {
          if (!currentUser.blockedUids.contains(doc['uid'])) {
            messages.add(LiveChatMessage.fromDocument(doc));
          }
          allMessages = messages;
        });
        return Expanded(
          child: ListView(
            reverse: true,
            children: allMessages,
          ),
        );
      },
    );
  }

  addMessage() {
    final messageId = Uuid().v4();
    int creationDate = DateTime.now().millisecondsSinceEpoch;
    liveChatMessagesRef
        .document(chatId)
        .collection('messages')
        .document(messageId)
        .setData({
      'uid': currentUser.uid,
      'displayName': currentUser.displayName,
      'message': message,
      'creationDate': creationDate,
      'red': currentUser.red,
      'green': currentUser.green,
      'blue': currentUser.blue,
      'messageId': messageId,
    }).whenComplete(() {
      liveChatController.clear();
      if (this.mounted) setState(() {
        _hasStartedTyping = false;
      });
      usersInChatRef
          .document(chatId)
          .collection('inChat')
          .document(currentUser.uid)
          .setData({});
    });
    liveChatLocationsRef
        .document(chatId)
        .updateData({
      'lastActive': DateTime.now().millisecondsSinceEpoch,
    });
    activityRef.document(currentUser.uid).collection('liveChatsJoined').document(chatId).setData({});
  }

  streamUserCountInChat() {
    usersInChatRef.document(chatId).collection('inChat').snapshots().listen((data){
      setState(() {
        inChatCount = data.documents.length;
      });
    });
  }

  buildChatHeader() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        Container(
          height: 25.0,
          width: screenWidth,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              '$inChatCount in chat',
              style: kAppBarTextStyle.copyWith(
                  color: kColorLightGray, fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Container(
          height: 1.0,
          color: kColorExtraLightGray,
        )
      ],
    );
  }

  _reasonToReport(BuildContext context) {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam',
        color: kColorRed,
        onTap: () {
          _reportLiveChat(context, 'Spam');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.angry,
        title: 'Innappropriate',
        color: kColorRed,
        onTap: () {
          _reportLiveChat(context, 'Innappropriate');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportLiveChat(BuildContext context, String reason) {
    bool canReport = chatId != null;
    canReport
        ? reportedLiveChatsRef.document(chatId).setData({
            'reportedByUid': currentUser.uid,
            'reason': reason,
            'chatId': chatId,
          }).whenComplete(() {
            kShowAlert(
              context: context,
              title: 'Successfully Reported',
              desc: 'Thank you for making HereMe a better place',
              buttonText: 'Dismiss',
              onPressed: () => Navigator.pop(context),
              color: kColorBlue,
            );
          })
        : kShowAlert(
            context: context,
            title: 'Whoops',
            desc: 'Unable to report at this time',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          );
  }

  _settingsActionSheet(BuildContext context) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Report Live Chat',
        iconData: FontAwesomeIcons.flag,
        color: kColorRed,
        onTap: () async {
          _reasonToReport(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel',
        iconData: FontAwesomeIcons.times,
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.mapMarkerAlt, color: kColorDarkThistle, size: 14.0,),
              SizedBox(width: 4.0),
              Text(city, style: kAppBarTextStyle),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
            color: kColorBlack62,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.ellipsisH, size: 20, color: kColorBlack62),
              onPressed: () => _settingsActionSheet(context),
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              buildChatHeader(),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragDown: (_) {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildMessages(),
                      Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: kColorExtraLightGray, width: 1.0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      style: kDefaultTextStyle,
                                      cursorColor: kColorLightGray,
                                      controller: liveChatController,
                                      onChanged: (value) {
                                        message = value;
                                        startedTyping();
                                      },
                                      onSubmitted: (_) {
                                        _hasStartedTyping
                                            ? addMessage()
                                            : kShowSnackbar(
                                                key: _scaffoldKey,
                                                text:
                                                    'Message cannot be empty or larger than 200 characters',
                                                backgroundColor: kColorRed);
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10.0),
                                        hintText:
                                            '${currentUser.displayName}: Join the convo...',
                                        hintStyle: kDefaultTextStyle.copyWith(
                                            color: kColorLightGray),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      _hasStartedTyping
                                          ? addMessage()
                                          : kShowSnackbar(
                                          key: _scaffoldKey,
                                          text:
                                          'Message cannot be empty or larger than 200 characters',
                                          backgroundColor: kColorRed);
                                    },
                                    child: _hasStartedTyping
                                        ? Animator(
                                            duration: Duration(milliseconds: 200),
                                            tween: Tween(begin: 0.8, end: 1.4),
                                            curve: Curves.easeInOutQuad,
                                            cycles: 1,
                                            builder: (anim) => Transform.scale(
                                              scale: anim.value,
                                              child: GestureDetector(
                                                onTap: () => addMessage(),
                                                child: Icon(FontAwesomeIcons.chevronCircleUp,
                                                    color: kColorDarkThistle, size: 16.0),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}

final reportedMessagesRef =
    Firestore.instance.collection('reportedLiveChatMessages');

class LiveChatMessage extends StatelessWidget {
  final String displayName;
  final String uid;
  final String message;
  final int creationDate;
  final int red;
  final int green;
  final int blue;
  final String messageId;

  LiveChatMessage({
    this.displayName,
    this.uid,
    this.message,
    this.creationDate,
    this.red,
    this.green,
    this.blue,
    this.messageId,
  });

  factory LiveChatMessage.fromDocument(DocumentSnapshot doc) {
    return LiveChatMessage(
      displayName: doc['displayName'],
      uid: doc['uid'],
      message: doc['message'],
      creationDate: doc['creationDate'],
      red: doc['red'] ?? 62,
      green: doc['green'] ?? 62,
      blue: doc['blue'] ?? 62,
      messageId: doc['messageId'],
    );
  }

  _reasonToReport(BuildContext context) {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam',
        color: kColorRed,
        onTap: () {
          _reportMessage(context, 'Spam');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.angry,
        title: 'Innappropriate',
        color: kColorRed,
        onTap: () {
          _reportMessage(context, 'Innappropriate');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportMessage(BuildContext context, String reason) {
    bool canReport = chatIdentifier != null && messageId != null;
    canReport
        ? reportedMessagesRef.document(messageId).setData({
      'displayName': displayName,
      'uid': uid,
      'message': message,
      'reason': reason,
      'messageId': messageId,
      'chatId': chatIdentifier,
    }).whenComplete(() {
      kShowAlert(
          context: context,
          title: 'Successfully Reported',
          desc: 'Thank you for making HereMe a better place',
          buttonText: 'Dismiss',
          onPressed: () => Navigator.pop(context),
          color: kColorBlue);
    })
        : kShowAlert(
      context: context,
      title: 'Whoops',
      desc: 'Unable to report at this time',
      buttonText: 'Try Again',
      onPressed: () => Navigator.pop(context),
      color: kColorRed,
    );
  }

  _goToHostUserProfile(BuildContext context) {
    if (uid != null) {
      bool isCurrentUser = currentUser.uid == uid;
      User user = User(uid: uid);
      UserResult result = UserResult(
          user: user, locationLabel: isCurrentUser ? 'Here' : 'Nearby');
      result.toProfile(context);
    }
  }

  _settingsActionSheet(BuildContext context) {
    bool isCurrentUser = currentUser.uid == uid;
    List<ReusableBottomActionSheetListTile> sheets = [];
    !isCurrentUser
        ? sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Report',
        iconData: FontAwesomeIcons.flag,
        color: kColorRed,
        onTap: () async {
          _reasonToReport(context);
        },
      ),
    )
        : SizedBox();
    !isCurrentUser
        ? sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Block',
        color: kColorRed,
        iconData: FontAwesomeIcons.ban,
        onTap: () async {
          kConfirmBlock(context, displayName, uid);
        },
      ),
    )
        : SizedBox();
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: !isCurrentUser ? "$displayName's Profile" : 'Your Profile',
        iconData: FontAwesomeIcons.user,
        onTap: () async {
          Navigator.pop(context);
          _goToHostUserProfile(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel',
        iconData: FontAwesomeIcons.times,
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 4.0, left: 4.0, top: 4.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: screenWidth,
          color: currentUser.uid == uid
              ? Color.fromRGBO(red, green, blue, 0.1)
              : Colors.transparent,
          child: GestureDetector(
            onTap: () => _settingsActionSheet(context),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$displayName: ',
                    style: kDefaultTextStyle.copyWith(
                        color: Color.fromRGBO(red, green, blue, 1.0),
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: message,
                    style: kDefaultTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
