import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:animator/animator.dart';

class LiveChatScreen extends StatefulWidget {
  final String title;
  final String chatId;
  final String chatHostUid;
  final String chatHostUsername;

  LiveChatScreen({this.title, this.chatId, this.chatHostUsername, this.chatHostUid});

  @override
  _LiveChatScreenState createState() => _LiveChatScreenState(
    title: this.title,
    chatId: this.chatId,
    chatHostUid: this.chatHostUid,
    chatHostUsername: this.chatHostUsername,
  );
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final String title;
  final String chatId;
  final String chatHostUid;
  final String chatHostUsername;
  _LiveChatScreenState({this.title, this.chatId, this.chatHostUsername, this.chatHostUid});

  TextEditingController liveChatController = TextEditingController();
  String message;
  bool _hasStartedTyping = false;
  final _messageFocus = FocusNode();

  startedTyping() {
    if (message.isNotEmpty) {
      setState(() {
        _hasStartedTyping = true;
      });
    } else {
      setState(() {
        _hasStartedTyping = false;
      });
    }
  }

  buildMessages() {
    return StreamBuilder(
      stream: liveChatMessagesRef
          .document(chatId)
          .collection('messages')
          .orderBy('creationDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<LiveChatMessage> messages = [];
        snapshot.data.documents.forEach((doc) {
          messages.add(LiveChatMessage.fromDocument(doc));
        });
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messages,
          ),
        );
      },
    );
  }

  addMessage() {
    liveChatMessagesRef.document(chatId).collection('messages').add({
      'uid': currentUser.uid,
      'username': currentUser.username,
      'message': message,
      'creationDate': DateTime.now().millisecondsSinceEpoch * 1000,
    }).whenComplete((){
      liveChatController.clear();
      setState(() {
        _hasStartedTyping = false;
      });
    });
//    bool isNotPostOwner = postOwnerId != currentUser.id;
//    if (isNotPostOwner) {
//      activityFeedRef.document(postOwnerId).collection('feedItems').add({
//        'type': 'comment',
//        'commentData': commentController.text,
//        'username': currentUser.username,
//        'userId': currentUser.id,
//        'userProfileImage': currentUser.photoUrl,
//        'postId': postId,
//        'mediaUrl': postMediaUrl,
//        'timestamp': timestamp,
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        title: Text(title, style: kAppBarTextStyle),
        backgroundColor: kColorOffWhite,
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack105,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildMessages(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: kColorThistle, width: 2.0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: kDefaultTextStyle,
                            cursorColor: kColorPurple,
                            controller: liveChatController,
                            onChanged: (value) {
                              message = value;
                              startedTyping();
                            },
                            onSubmitted: (_) {
                              addMessage();
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                              hintText: 'Join the convo...',
                              hintStyle: kDefaultTextStyle.copyWith(color: kColorLightGray),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            addMessage();
                          },
                          child: _hasStartedTyping ? Animator(
                            duration: Duration(milliseconds: 200),
                            tween: Tween(begin: 0.8, end: 1.4),
                            curve: Curves.easeInOutQuad,
                            cycles: 1,
                            builder: (anim) => Transform.scale(
                              scale: anim.value,
                              child: IconButton(
                                onPressed: () => addMessage(),
                                icon: Icon(FontAwesomeIcons.chevronCircleRight, color: kColorBlack105),
                                splashColor: Colors.grey[200],
                                highlightColor: Colors.transparent,
                                iconSize: 20.0,
                              ),
                            ),
                          ) : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveChatMessage extends StatelessWidget {
  final String username;
  final String uid;
  final String message;
  final int creationDate;

  LiveChatMessage({this.username, this.uid, this.message, this.creationDate});

  factory LiveChatMessage.fromDocument(DocumentSnapshot doc) {
    return LiveChatMessage(
      username: doc['username'],
      uid: doc['uid'],
      message: doc['message'],
      creationDate: doc['creationDate'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0, left: 2.0, top: 10.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$username: ',
                style: kDefaultTextStyle.copyWith(
                    color: kColorPurple, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: message,
                style: kDefaultTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$username: ',
                  style: kDefaultTextStyle.copyWith(
                      color: kColorPurple, fontWeight: FontWeight.w300),
                ),
                TextSpan(
                  text: message,
                  style: kDefaultTextStyle,
                ),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }
}
