import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';

import '../constants.dart';

class UpdatePost extends StatelessWidget {

  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;

  UpdatePost({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return buildTextPost(context, screenWidth);
  }
}
