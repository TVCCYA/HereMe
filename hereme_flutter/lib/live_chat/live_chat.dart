import 'package:flutter/material.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';

class LiveChat extends StatelessWidget {
  final String title;
  final String chatId;
  final String chatHostDisplayName;
  final String chatHostUid;
  final int creationDate;
  final int hostRed;
  final int hostGreen;
  final int hostBlue;
  final String duration;
  final String lastMessageDisplayName;
  final String lastMessage;
  final int lastRed;
  final int lastGreen;
  final int lastBlue;
  final Function onTap;

  final List<String> invites;

  LiveChat({
    this.title,
    this.chatId,
    this.chatHostDisplayName,
    this.chatHostUid,
    this.creationDate,
    this.hostRed,
    this.hostGreen,
    this.hostBlue,
    this.duration,
    this.lastMessageDisplayName,
    this.lastMessage,
    this.lastRed,
    this.lastGreen,
    this.lastBlue,
    this.onTap,
    this.invites,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
          title: Text(
            title,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle,
          ),
          subtitle: lastMessage != null ? Container(
            color: currentUser.displayName == lastMessageDisplayName
                ? Color.fromRGBO(currentUser.red, currentUser.green, currentUser.blue, 0.1)
                : Colors.transparent,
              child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$lastMessageDisplayName: ',
                  style: kDefaultTextStyle.copyWith(
                      color: Color.fromRGBO(lastRed ?? 91, lastGreen ?? 71, lastBlue ?? 188, 1.0),
                      fontWeight: FontWeight.w700,
                    fontSize: 14.0
                  ),
                ),
                TextSpan(
                  text: lastMessage,
                  style: kDefaultTextStyle.copyWith(fontSize: 14.0),
                ),
              ],
            ),
          ))
              : Text(
            '* Newly Created *',
            style: kDefaultTextStyle.copyWith(fontSize: 14.0, color: kColorGreen),
          ),
          trailing: Text(
            duration,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorLightGray,
            ),
          ),
          onTap: onTap,
        ),
        Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Container(height: 0.5, color: kColorExtraLightGray),
        )
      ],
    );
  }
}
