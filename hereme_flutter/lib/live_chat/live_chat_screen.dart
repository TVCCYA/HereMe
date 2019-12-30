import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:animator/animator.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:uuid/uuid.dart';

String chatIdentifier;
final reportedLiveChatsRef = Firestore.instance.collection('reportedLiveChats');

class LiveChatScreen extends StatefulWidget {
  final String title;
  final String chatId;
  final String chatHostUid;
  final String chatHostDisplayName;
  final int hostRed;
  final int hostGreen;
  final int hostBlue;
  final String duration;

  LiveChatScreen({
    this.title,
    this.chatId,
    this.chatHostDisplayName,
    this.chatHostUid,
    this.hostRed,
    this.hostGreen,
    this.hostBlue,
    this.duration,
  });

  @override
  _LiveChatScreenState createState() => _LiveChatScreenState(
        title: this.title,
        chatId: this.chatId,
        chatHostUid: this.chatHostUid,
        chatHostDisplayName: this.chatHostDisplayName,
        hostRed: this.hostRed,
        hostGreen: this.hostGreen,
        hostBlue: this.hostBlue,
        duration: this.duration,
      );
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final String title;
  final String chatId;
  final String chatHostUid;
  final String chatHostDisplayName;
  final int hostRed;
  final int hostGreen;
  final int hostBlue;
  final String duration;

  _LiveChatScreenState({
    this.title,
    this.chatId,
    this.chatHostDisplayName,
    this.chatHostUid,
    this.hostRed,
    this.hostGreen,
    this.hostBlue,
    this.duration,
  });

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController liveChatController = TextEditingController();
  String message;
  bool _hasStartedTyping = false;
  bool _hostAnonymous = false;
  List<dynamic> uidsInChat = [];
  int now = DateTime.now().millisecondsSinceEpoch;
  bool hasChatEnded = false;

  @override
  void initState() {
    super.initState();
    isHostAnonymous();
    streamUserCountInChat();
    if (this.mounted) setState(() {
      chatIdentifier = chatId;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    streamChatDuration();
  }

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  isHostAnonymous() {
    if (chatHostDisplayName.isEmpty) {
      if (this.mounted) setState(() {
        _hostAnonymous = true;
      });
    } else {
      if (this.mounted) setState(() {
        _hostAnonymous = false;
      });
    }
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
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            children: allMessages,
          ),
        );
      },
    );
  }

  addMessage() {
    final messageId = Uuid().v4();
    liveChatMessagesRef
        .document(chatId)
        .collection('messages')
        .document(messageId)
        .setData({
      'uid': currentUser.uid,
      'displayName': currentUser.displayName,
      'message': message,
      'creationDate': DateTime.now().millisecondsSinceEpoch,
      'red': currentUser.red,
      'green': currentUser.green,
      'blue': currentUser.blue,
      'messageId': messageId,
    }).whenComplete(() {
      liveChatController.clear();
      if (this.mounted) setState(() {
        _hasStartedTyping = false;
      });
    });
    liveChatsRef
        .document(chatHostUid)
        .collection('chats')
        .document(chatId)
        .updateData({
      'lastMessage': message,
      'lastMessageDisplayName': currentUser.displayName,
      'lastRed': currentUser.red,
      'lastGreen': currentUser.green,
      'lastBlue': currentUser.blue,
    });
    bool isNotChatHost = chatHostUid != currentUser.uid;
    if (isNotChatHost) {
      activityRef
          .document(currentUser.uid)
          .collection('feedItems')
          .document(chatId)
          .setData({
        'type': 'liveChatMessage',
        'title': title,
        'chatId': chatId,
        'message': message,
        'messageId': messageId,
        'creationDate': DateTime.now().millisecondsSinceEpoch,
        'uid': chatHostUid,
        'hostDisplayName': chatHostDisplayName,
        'hostRed': hostRed,
        'hostGreen': hostGreen,
        'hostBlue': hostBlue
      });
    }
  }

  streamChatDuration() {
    bool chatEnded;
    Stream<DocumentSnapshot> streamSnaps =
        liveChatLocationsRef.document(chatId).snapshots();
    streamSnaps.forEach((snapshot) {
      final endDate = snapshot.data['endDate'];
      int timeLeft = endDate - DateTime.now().millisecondsSinceEpoch;
      chatEnded = timeLeft <= 0;
      if (chatEnded) {
        if (this.mounted) setState(() {
            hasChatEnded = true;
          });
      }
    });
  }

  streamUserCountInChat() {
    Stream<QuerySnapshot> streamSnaps =
        liveChatMessagesRef.document(chatId).collection('messages').snapshots();
    List<String> uids = [];
    streamSnaps.forEach((snapshot) {
      snapshot.documents.forEach((doc) {
        String uid = doc.data['uid'];
        uids.add(uid);
      });
      if (this.mounted) setState(() {
          uids.forEach((i) {
            if (!uidsInChat.contains(i)) {
              this.uidsInChat.add(i);
            }
          });
        });
      uidsInChat.forEach((uid) {
        usersInChatRef
            .document(chatId)
            .collection('inChat')
            .document(uid)
            .setData({'uid': uid});
      });
    });
  }

  buildChatHeader() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        Container(
          height: 39.0,
          width: screenWidth,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () => _hostAnonymous
                    ? print('do nothing')
                    : _goToHostUserProfile(),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Host: ',
                          style: kAppBarTextStyle.copyWith(
                              color: kColorBlack71, fontSize: 16.0),
                        ),
                        _hostAnonymous
                            ? TextSpan(
                                text: 'Anonymous',
                                style: kAppBarTextStyle.copyWith(
                                  color: kColorLightGray,
                                ))
                            : TextSpan(
                                text: chatHostDisplayName,
                                style: kAppBarTextStyle.copyWith(
                                  fontSize: 16.0,
                                  color: Color.fromRGBO(hostRed ?? 95,
                                      hostGreen ?? 71, hostBlue ?? 188, 1.0,),
                                )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${uidsInChat.length}',
                        style: kAppBarTextStyle.copyWith(
                            color: kColorBlack71, fontSize: 16.0),
                      ),
                      TextSpan(
                        text: ' in chat',
                        style: kAppBarTextStyle.copyWith(
                            color: kColorBlack71, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1.0,
          color: kColorExtraLightGray,
        )
      ],
    );
  }

  _goToHostUserProfile() {
    if (chatHostUid != null) {
      bool isCurrentUser = currentUser.uid == chatHostUid;
      User user = User(uid: chatHostUid);
      UserResult result = UserResult(
          user: user, locationLabel: isCurrentUser ? 'Here' : 'Nearby');
      result.toProfile(context);
    }
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
            'displayName': chatHostDisplayName,
            'uid': chatHostUid,
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
    _hostAnonymous
        ? SizedBox()
        : sheets.add(
            ReusableBottomActionSheetListTile(
              title: "$chatHostDisplayName's Profile",
              iconData: FontAwesomeIcons.user,
              onTap: () async {
                Navigator.pop(context);
                _goToHostUserProfile();
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        title: FlatButton(
          onPressed: () => _settingsActionSheet(context),
          child: Text(title, style: kAppBarTextStyle),
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                duration,
                style:
                    kAppBarTextStyle.copyWith(color: kColorLightGray, fontSize: 16.0),
              ),
            ),
          ),
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
                padding: EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildMessages(),
                    !hasChatEnded
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: kColorExtraLightGray, width: 2.0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    style: kDefaultTextStyle,
                                    cursorColor: kColorRed,
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
                                            child: IconButton(
                                              onPressed: () => addMessage(),
                                              icon: Icon(
                                                  FontAwesomeIcons
                                                      .chevronCircleRight,
                                                  color: kColorBlack71),
                                              splashColor: kColorExtraLightGray,
                                              highlightColor:
                                                  Colors.transparent,
                                              iconSize: 20.0,
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ],
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
      red: doc['red'] ?? 95,
      green: doc['green'] ?? 71,
      blue: doc['blue'] ?? 188,
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
      padding: EdgeInsets.only(right: 4.0, left: 2.0, top: 10.0, bottom: 8.0),
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
