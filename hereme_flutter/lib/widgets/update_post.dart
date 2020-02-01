import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';

import '../constants.dart';

// ignore: must_be_immutable
class UpdatePost extends StatelessWidget {
  final String currentUserId = currentUser.uid;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;
  final String displayName;

  Map likes;
  bool isLiked;

  UpdatePost({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.displayName,
    this.likes,
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

  _settingsActionSheet(BuildContext context, bool isPhotoPost) {
    bool isCurrentUser = currentUser.uid == uid;
    List<ReusableBottomActionSheetListTile> sheets = [];
    if (isCurrentUser) {
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Remove Post',
          iconData: FontAwesomeIcons.trash,
          color: kColorRed,
          onTap: () async {
            Navigator.pop(context);
            kShowAlertMultiButtons(
              context: context,
              title: 'Remove Post',
              desc: 'Are you sure you want to remove this post?',
              color1: kColorRed,
              color2: kColorLightGray,
              buttonText1: 'Remove',
              buttonText2: 'Cancel',
              onPressed1: () {
                if (isPhotoPost) {
                  FirebaseStorage.instance
                      .ref()
                      .child('update_images/$uid/$id')
                      .delete();
                }
                kHandleRemoveDataAtId(id, uid, 'update', 'posts');
                Navigator.pop(context);
              },
              onPressed2: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    } else {
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Report',
          iconData: FontAwesomeIcons.flag,
          color: kColorRed,
          onTap: () async {
//          _reasonToReport(context);
          },
        ),
      );
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Block',
          color: kColorRed,
          iconData: FontAwesomeIcons.ban,
          onTap: () async {
//          kConfirmBlock(context, displayName, uid);
          },
        ),
      );
    }
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
    return GestureDetector(
      onTap: () => _settingsActionSheet(context, false),
      child: Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: screenWidth - 82,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$displayName: ',
                      style: kDefaultTextStyle.copyWith(
                          color: Color.fromRGBO(
                              currentUser.red ?? 71,
                              currentUser.green ?? 71,
                              currentUser.blue ?? 71,
                              1.0),
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
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: GestureDetector(
                child: Icon(!isLiked ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart,
                    color: !isLiked ? kColorLightGray : kColorRed, size: 16),
                onTap: () => handleLikePost(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildPhotoPost(BuildContext context, double screenWidth) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => _settingsActionSheet(context, true),
          child: Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: screenWidth - 82,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${currentUser.displayName ?? currentUser.username}: ',
                          style: kDefaultTextStyle.copyWith(
                              color: Color.fromRGBO(
                                  currentUser.red ?? 71,
                                  currentUser.green ?? 71,
                                  currentUser.blue ?? 71,
                                  1.0),
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
                GestureDetector(
                  child: Icon(!isLiked ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart,
                      color: !isLiked ? kColorLightGray : kColorRed, size: 16),
                  onTap: () => handleLikePost(),
                ),
              ],
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

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': false});
        isLiked = false;
        likes[currentUserId] = false;
    } else if (!_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': true});
        isLiked = true;
        likes[currentUserId] = true;
    }
  }

  buildLinkPost() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$displayName: ',
                style: kDefaultTextStyle.copyWith(
                    color: Color.fromRGBO(
                        currentUser.red ?? 71,
                        currentUser.green ?? 71,
                        currentUser.blue ?? 71,
                        1.0),
                    fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '* linked a new account *',
                style: kDefaultTextStyle.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  determineFeedItem(BuildContext context, double screenWidth) {
    if (type == 'text') {
      return buildTextPost(context, screenWidth);
    } else if (type == 'photo') {
      return buildPhotoPost(context, screenWidth);
    } else if (type == 'link') {
      return buildLinkPost();
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    isLiked = likes[currentUserId] == true;
    final double screenWidth = MediaQuery.of(context).size.width;
    return determineFeedItem(context, screenWidth);
  }
}
