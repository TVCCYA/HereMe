import 'package:flutter/material.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import 'live_chat_screen.dart';

class LiveChatResult extends StatelessWidget {
  final String title;
  final int creationDate;
  final String chatId;
  final String chatHostUsername;
  final String chatHostUid;

  LiveChatResult(
      {this.title,
      this.creationDate,
      this.chatId,
      this.chatHostUid,
      this.chatHostUsername});

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          contentPadding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
          title: Text(
            title,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
                fontWeight: FontWeight.w600, fontSize: 18.0),
          ),
          subtitle: Text(
            'Last message goes here',
            style: kDefaultTextStyle,
          ),
          onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => LiveChatScreen(
            title: title ?? '',
            chatId: chatId,
            chatHostUsername: chatHostUsername,
            chatHostUid: chatHostUid,
          ))),
          trailing: Text(
            date(),
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorLightGray,
            ),
          ),
        ),
        // separator line
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(height: 0.5, color: Colors.grey[300]),
        )
      ],
    );
  }
}
