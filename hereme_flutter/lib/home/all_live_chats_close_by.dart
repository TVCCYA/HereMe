import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/live_chat/live_chat_result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
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
            final hostRed = chat.data['hostRed'] ?? 91;
            final hostGreen = chat.data['hostGreen'] ?? 71;
            final hostBlue = chat.data['hostBlue'] ?? 188;
            final endDate = chat.data['endDate'];

            GeoPoint point = chat.data['position']['geopoint'];
            double distance = geo
                .point(latitude: point.latitude, longitude: point.longitude)
                .distance(lat: latitude, lng: longitude);
            double distanceFromChat = distance / 1.609;

            int timeLeft = endDate - DateTime.now().millisecondsSinceEpoch;
            bool hasChatEnded = timeLeft <= 0;

            if (hasChatEnded) {
              kHandleRemoveDataAtId(chatId, hostUid,'liveChats', 'chats');
              kRemoveLiveChatMessages(chatId);
              liveChatLocationsRef.document(chatId).delete();
            }

            final displayedChat = LiveChatResult(
              title: title,
              creationDate: creationDate,
              chatId: chatId,
              chatHostUid: hostUid,
              chatHostDisplayName: hostDisplayName,
              hostRed: hostRed,
              hostGreen: hostGreen,
              hostBlue: hostBlue,
              duration: kTimeRemaining(timeLeft),
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
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
        child: Theme(
          data: kTheme(context),
          child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            waterDropColor: Colors.grey[200],
            idleIcon: Icon(
              FontAwesomeIcons.commentDots,
              color: kColorPurple,
              size: 18.0,
            ),
            complete: Icon(
              FontAwesomeIcons. arrowDown,
              color: kColorLightGray,
              size: 20.0,
            ),
            failed: Icon(
              FontAwesomeIcons.times,
              color: kColorRed,
              size: 20.0,
            ),
          ),
          controller: _refreshController,
          onRefresh: () async {
              kShowSnackbar(
                key: _scaffoldKey,
                text: 'Your feed will auto update when a new Live Chat has started within your vicinity',
                backgroundColor: kColorBlack71,
              );
              _refreshController.refreshCompleted();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50.0),
              child: streamCloseByChats(),
            ),
          ),
        ),
      ),
    );
  }
}
