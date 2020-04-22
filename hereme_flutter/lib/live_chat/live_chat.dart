import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/live_chat/live_chat_screen.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';

class LiveChat extends StatefulWidget {
  final String chatId;
  final int creationDate;
  final String city;

  LiveChat({
    this.chatId,
    this.creationDate,
    this.city,
  });

  factory LiveChat.fromDocument(DocumentSnapshot doc) {
    return LiveChat(
      chatId: doc['chatId'],
      creationDate: doc['creationDate'],
      city: doc['city'],
    );
  }

  @override
  _LiveChatState createState() => _LiveChatState(
    chatId: chatId,
    creationDate: creationDate,
    city: city,
  );
}

class _LiveChatState extends State<LiveChat>
    with SingleTickerProviderStateMixin {

  final String chatId;
  final int creationDate;
  final String city;

  _LiveChatState({
    this.chatId,
    this.creationDate,
    this.city,
  });

  TabController _tabController;
  List<dynamic> uidsInChat = [];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: kColorBlack62, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 4,
          brightness: Brightness.light,
          centerTitle: true,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Theme(
            data: kTheme(context),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
              indicatorPadding:
              EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
              indicatorWeight: 1.5,
              indicatorColor: kColorRed,
              labelColor: kColorRed,
              unselectedLabelColor: kColorLightGray,
              labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
              tabs: [
                Tab(text: 'Nearby'),
                Tab(text: 'Joined'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            LiveChatResult(chatId: chatId, creationDate: creationDate, city: city, inChatCount: uidsInChat.length,),
            Container()
          ],
        ),
      ),
    );
  }
}

class LiveChatResult extends StatelessWidget {
  final String chatId;
  final int creationDate;
  final String city;
  final int inChatCount;

  LiveChatResult({
    this.chatId,
    this.creationDate,
    this.city,
    this.inChatCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Live Chat closest to you in $city', style: kAppBarTextStyle,),
                Text('In Chat: $inChatCount', style: kDefaultTextStyle.copyWith(color: kColorLightGray),),
                Text('Last Active: 10 mins ago', style: kDefaultTextStyle.copyWith(color: kColorLightGray),),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ReusableRoundedCornerButton(
                    width: 30,
                    text: 'Join',
                    textColor: kColorLightGray,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LiveChatScreen(chatId: chatId,))),
//              textColor: kColorLightGray,
                  ),
                )
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

