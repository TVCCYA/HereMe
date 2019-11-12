import 'package:flutter/material.dart';
import 'package:hereme_flutter/live_chat/live_chat_screen.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import '../constants.dart';
import 'package:hereme_flutter/home/home.dart';

class ActivityFeedItem extends StatelessWidget {
// for pending knocks/last profile visited
  final String type;
  final String username;
  final String uid;
  final String city;
  final String imageUrl;
  final Function onTap;
  final int creationDate;

// for live chat
  final String title;
  final String chatId;
  final String chatHostDisplayName;
  final int hostRed;
  final int hostGreen;
  final int hostBlue;
  final int duration;
  final String lastMessage;

  ActivityFeedItem({
    this.type,
    this.username,
    this.uid,
    this.city,
    this.imageUrl,
    this.onTap,
    this.creationDate,

    this.title,
    this.chatId,
    this.chatHostDisplayName,
    this.hostRed,
    this.hostGreen,
    this.hostBlue,
    this.duration,
    this.lastMessage,
  });

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  buildPendingKnock() {
    return ListTile(
      dense: true,
      contentPadding:
      EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      title: Text(
        username,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle,
      ),
      subtitle: Text(
        'Pending Knock',
        style: kDefaultTextStyle.copyWith(color: kColorLightGray, fontSize: 14.0),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: cachedNetworkImage(imageUrl),
      ),
      onTap: onTap,
      trailing: Text(
        date(),
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle.copyWith(
          fontSize: 12.0,
          color: kColorLightGray,
        ),
      ),
    );
  }

  buildLiveChatMessage(context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
      title: Text(
        title,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle,
      ),
      subtitle: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${currentUser.displayName}: ',
              style: kDefaultTextStyle.copyWith(
                  color: kColorLightGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0
              ),
            ),
            TextSpan(
              text: lastMessage,
              style: kDefaultTextStyle.copyWith(fontSize: 14.0, color: kColorLightGray),
            ),
          ],
        ),
      ),
      trailing: Text(
        date(),
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle.copyWith(
          fontSize: 12.0,
          color: kColorLightGray,
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
                  chatHostUid: uid ?? '',
                  hostRed: hostRed ?? 95,
                  hostGreen: hostGreen ?? 71,
                  hostBlue: hostBlue ?? 188,
                )
                    : CreateDisplayName()));
      },
    );
  }
  
  buildRecentProfileVisit(context) {
    return ListTile(
      dense: true,
      contentPadding:
      EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      title: Text(
        username,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle,
      ),
      subtitle: Text(
        'Recent Profile Visit',
        style: kDefaultTextStyle.copyWith(color: kColorLightGray, fontSize: 14.0),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: cachedNetworkImage(imageUrl),
      ),
      onTap: () {
        User user = User(uid: uid);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(
          user: user,
          locationLabel: city,
        )));
      },
      trailing: Text(
        date(),
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle.copyWith(
          fontSize: 12.0,
          color: kColorLightGray,
        ),
      ),
    );
  }

  buildLiveChatInvite(context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
      title: Text(
        'You are invited to $title',
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle,
      ),
      subtitle: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Host: ',
              style: kDefaultTextStyle.copyWith(
                  color: kColorLightGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0
              ),
            ),
            chatHostDisplayName.isNotEmpty ? TextSpan(
              text: chatHostDisplayName,
              style: kDefaultTextStyle.copyWith(fontSize: 14.0, color: Color.fromRGBO(hostRed, hostGreen, hostBlue, 1.0)),
            ) : TextSpan(
              text: 'Anonymous',
              style: kDefaultTextStyle.copyWith(fontSize: 14.0, color: kColorLightGray),
            ),
          ],
        ),
      ),
      trailing: Text(
        date(),
        overflow: TextOverflow.fade,
        softWrap: false,
        style: kDefaultTextStyle.copyWith(
          fontSize: 12.0,
          color: kColorLightGray,
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
                  chatHostUid: uid ?? '',
                  hostRed: hostRed ?? 95,
                  hostGreen: hostGreen ?? 71,
                  hostBlue: hostBlue ?? 188,
                )
                    : CreateDisplayName()));
      },
    );
  }

  determineFeedItem(context) {
    if (type == 'pendingKnock') {
      return buildPendingKnock();
    } else if (type == 'liveChatMessage') {
      return buildLiveChatMessage(context);
    } else if (type == 'recentProfileVisit') {
      return buildRecentProfileVisit(context);
    } else if (type == 'liveChatInvite') {
      buildLiveChatInvite(context);
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        determineFeedItem(context),
        // separator line
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(height: 0.5, color: Colors.grey[100]),
        )
      ],
    );
    ;
  }
}
