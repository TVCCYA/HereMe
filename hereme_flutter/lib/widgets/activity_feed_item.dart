import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/live_chat/live_chat_screen.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import '../constants.dart';

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
  final String duration;
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
        style:
            kDefaultTextStyle.copyWith(color: kColorLightGray, fontSize: 14.0),
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
      contentPadding:
          EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
      title: RichText(
        text: chatHostDisplayName.isNotEmpty
            ? TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: kAppBarTextStyle.copyWith(
                      fontSize: 16.0,
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
              )
            : TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: kAppBarTextStyle.copyWith(
                      fontSize: 16.0,
                    ),
                  ),
                  TextSpan(
                    text: " hosted anonymously",
                    style: kDefaultTextStyle,
                  ),
                ],
              ),
      ),
      subtitle: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${currentUser.displayName}: ',
              style: kDefaultTextStyle.copyWith(
                  color: kColorLightGray,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0),
            ),
            TextSpan(
              text: lastMessage,
              style: kDefaultTextStyle.copyWith(
                  fontSize: 14.0, color: kColorLightGray),
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
                        chatId: chatId,
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
        'Last Profile Visited',
        style:
            kDefaultTextStyle.copyWith(color: kColorLightGray, fontSize: 14.0),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: cachedNetworkImage(imageUrl),
      ),
      onTap: () {
        User user = User(uid: uid);
        print(uid);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Profile(user: user, locationLabel: 'Around')));
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
      contentPadding:
          EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "You are invited to: ",
              style: kDefaultTextStyle,
            ),
            TextSpan(
              text: title,
              style: kAppBarTextStyle.copyWith(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
      subtitle: chatHostDisplayName.isNotEmpty
          ? RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Hosted by: ',
                    style: kDefaultTextStyle.copyWith(
                        color: kColorLightGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0),
                  ),
                  TextSpan(
                    text: chatHostDisplayName,
                    style: kDefaultTextStyle.copyWith(
                        fontSize: 14.0,
                        color:
                            Color.fromRGBO(hostRed, hostGreen, hostBlue, 1.0)),
                  ),
                ],
              ))
          : Text(
              'Hosted Anonymously',
              style: kDefaultTextStyle.copyWith(
                  fontSize: 14.0, color: kColorLightGray),
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
        _liveChatInviteActionSheet(context: context);
      },
    );
  }

  _liveChatInviteActionSheet({BuildContext context}) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Ignore',
        iconData: FontAwesomeIcons.minusCircle,
        color: kColorRed,
        onTap: () {
          _ignoreLiveChat();
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Enter Live Chat',
        iconData: FontAwesomeIcons.commentDots,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => currentUser.displayName != null
                      ? LiveChatScreen(
                          chatId: chatId,
                        )
                      : CreateDisplayName()));
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

  _ignoreLiveChat() {
    activityRef
        .document(currentUser.uid)
        .collection('feedItems')
        .document(chatId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        snapshot.reference.delete();
      }
    });
  }

  determineFeedItem(context) {
    if (type == 'pendingKnock') {
      return buildPendingKnock();
    } else if (type == 'liveChatMessage') {
      return buildLiveChatMessage(context);
    } else if (type == 'recentProfileVisit') {
      return buildRecentProfileVisit(context);
    } else if (type == 'liveChatInvite') {
      return buildLiveChatInvite(context);
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
          child: Container(height: 0.5, color: kColorExtraLightGray),
        )
      ],
    );
    ;
  }
}
