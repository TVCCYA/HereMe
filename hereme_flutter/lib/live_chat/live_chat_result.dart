import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import 'live_chat_screen.dart';

class LiveChatResult extends StatelessWidget {
  final String title;
  final int creationDate;
  final String chatId;
  final String chatHostDisplayName;
  final String chatHostUid;
  final int hostRed;
  final int hostGreen;
  final int hostBlue;
  final String duration;
  final double distanceFromChat;

  LiveChatResult({
    this.title,
    this.creationDate,
    this.chatId,
    this.chatHostUid,
    this.chatHostDisplayName,
    this.hostRed,
    this.hostGreen,
    this.hostBlue,
    this.duration,
    this.distanceFromChat,
  });

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
              EdgeInsets.only(left: 12.0, right: 16.0, top: 4.0, bottom: 4.0),
          title: RichText(
            text: chatHostDisplayName.isNotEmpty ? TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: kAppBarTextStyle.copyWith(
                    fontSize: 17.0,
                  ),
                ),
                TextSpan(
                  text: " hosted by: ",
                  style: kDefaultTextStyle,
                ),
                TextSpan(
                  text: chatHostDisplayName,
                  style: kDefaultTextStyle.copyWith(
                    color: Color.fromRGBO(hostRed, hostGreen, hostBlue, 1.0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ) : TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: kAppBarTextStyle.copyWith(
                    fontSize: 17.0,
                  ),
                ),
                TextSpan(
                  text: " hosted anonymously",
                  style: kDefaultTextStyle,
                ),
              ],
            ),
          ),
          subtitle: Row(
            children: <Widget>[
              distanceFromChat == 0 ? Icon(
                FontAwesomeIcons.mapMarkerAlt,
                size: 12.0,
                color: kColorPurple,
              ) : Icon(
                FontAwesomeIcons.searchLocation,
                size: 12.0,
                color: kColorBlue,
              ),
              SizedBox(width: 2.0),
              Text(
                distanceFromChat == 0 ? 'Here' : '${distanceFromChat.toStringAsFixed(5)} miles away',
                style: kDefaultTextStyle.copyWith(fontSize: 14.0),
              ),
            ],
          ),
          trailing: Text(
            duration,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorRed,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => currentUser.displayName != null
                        ? LiveChatScreen(
                      title: title ?? '',
                      chatId: chatId,
                      chatHostDisplayName: chatHostDisplayName ?? '',
                      chatHostUid: chatHostUid ?? '',
                      hostRed: hostRed ?? 95,
                      hostGreen: hostGreen ?? 71,
                      hostBlue: hostBlue ?? 188,
                      duration: duration,
                    )
                        : CreateDisplayName()));
          },
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
