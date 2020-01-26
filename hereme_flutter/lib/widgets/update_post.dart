import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';

import '../constants.dart';

class UpdatePost extends StatelessWidget {

  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;

  UpdatePost({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
  });

  factory UpdatePost.fromDocument(DocumentSnapshot doc) {
    return UpdatePost(
      photoUrl: doc['photoUrl'],
      uid: doc['uid'],
      title: doc['title'],
      creationDate: doc['creationDate'],
      id: doc['id'],
    );
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
//          _reasonToReport(context);
        },
      ),
    ) : SizedBox();
    !isCurrentUser
        ? sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Block',
        color: kColorRed,
        iconData: FontAwesomeIcons.ban,
        onTap: () async {
//          kConfirmBlock(context, displayName, uid);
        },
      ),
    ) : SizedBox();
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel',
        iconData: FontAwesomeIcons.times,
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  buildTextPost(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(right: 4.0, left: 2.0, top: 10.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: screenWidth,
          child: GestureDetector(
            onTap: () => _settingsActionSheet(context),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${currentUser.displayName ?? currentUser.username}: ',
                    style: kDefaultTextStyle.copyWith(
                        color: Color.fromRGBO(currentUser.red ?? 71, currentUser.green ?? 71, currentUser.blue ?? 71, 1.0),
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: title,
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

  buildPhotoPost(BuildContext context, double screenWidth) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Container(
          width: screenWidth,
          child: GestureDetector(
            onTap: () => _settingsActionSheet(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${currentUser.displayName ?? currentUser.username}: ',
                      style: kDefaultTextStyle.copyWith(
                          color: Color.fromRGBO(currentUser.red ?? 71, currentUser.green ?? 71, currentUser.blue ?? 71, 1.0),
                          fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: title,
                      style: kDefaultTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, SizeRoute(page: ProfileImageFullScreen(photoUrl)));
          },
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            height: screenHeight / 5,
            width: screenHeight / 5,
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }

  determineFeedItem(BuildContext context, double screenWidth) {
    if (type == 'text') {
      return buildTextPost(context, screenWidth);
    } else if (type == 'photo') {
      return buildPhotoPost(context, screenWidth);
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return determineFeedItem(context, screenWidth);
  }
}
