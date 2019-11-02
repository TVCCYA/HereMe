import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/live_chat/live_chat_result.dart';

import 'home.dart';

class AllLiveChatsCloseBy extends StatefulWidget {
  final double latitude;
  final double longitude;
  AllLiveChatsCloseBy({this.latitude, this.longitude});

  @override
  _AllLiveChatsCloseByState createState() => _AllLiveChatsCloseByState(
    latitude: this.latitude,
    longitude: this.longitude,
  );
}

class _AllLiveChatsCloseByState extends State<AllLiveChatsCloseBy> {
  final double latitude;
  final double longitude;
  _AllLiveChatsCloseByState({this.latitude, this.longitude});

  streamCloseByChats() {
    Geoflutterfire geo = Geoflutterfire();
    Query collectionRef = liveChatLocationsRef;
    Stream<List<DocumentSnapshot>> stream =
    geo.collection(collectionRef: collectionRef).within(
      center: geo.point(latitude: latitude, longitude: longitude),
      radius: 0.4,
      field: 'position',
      strictMode: true,
    );

    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return circularProgress();
          }
          List<LiveChatResult> chatsAround = [];
          List<DocumentSnapshot> chats = [];
          for (var data in snapshot.data) {
            chats.add(data);
          }
          for (var chat in chats) {
            final title = chat.data['title'];
            final creationDate = chat.data['creationDate'];
            final chatId = chat.data['chatId'];
            final hostDisplayName = chat.data['hostDisplayName'] ?? '';
            final hostUid = chat.data['uid'];
            final hostRed = chat.data['hostRed'];
            final hostGreen = chat.data['hostGreen'];
            final hostBlue = chat.data['hostBlue'];
            final duration = chat.data['duration'];
            GeoPoint point = chat.data['position']['geopoint'];
            double distance = geo.point(latitude: point.latitude, longitude: point.longitude)
                .distance(lat: latitude, lng: longitude);
            double distanceFromChat = distance / 1.609;

            final displayedChat = LiveChatResult(
              title: title,
              creationDate: creationDate,
              chatId: chatId,
              chatHostUid: hostUid,
              chatHostDisplayName: hostDisplayName,
              hostRed: hostRed,
              hostGreen: hostGreen,
              hostBlue: hostBlue,
              duration: duration,
              distanceFromChat: distanceFromChat,
            );
            if(!currentUser.blockedUids.contains(hostUid)) {
              chatsAround.add(displayedChat);
            }
          }
          if (chatsAround.isNotEmpty) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                    child: Text('All Live Chats Within 1 Mile',
                        style: kAppBarTextStyle.copyWith(
                            fontSize: 18.0)),
                  ),
                  Column(children: chatsAround),
                ],
              ),
            );
          } else {
            return Container(
              height: 150.0,
              child: Center(
                child: Text(
                  'No Live Chats Nearby',
                  style: kAppBarTextStyle,
                ),
              ),
            );
          }
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        backgroundColor: kColorOffWhite,
        elevation: 2.0,
        title: Text('Close By', style: kAppBarTextStyle),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            Flushbar(
              messageText: Text(
                'Your feed will auto update when a new Live Chat has started within your vicinity',
                style: kDefaultTextStyle.copyWith(color: Colors.white, fontSize: 14.0),
              ),
              backgroundColor: kColorBlack71,
              duration: Duration(seconds: 5),
            )..show(context);
          },
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50.0),
              physics: AlwaysScrollableScrollPhysics(),
              child: streamCloseByChats(),
            ),
          ),
        ),
      ),
    );
  }
}
