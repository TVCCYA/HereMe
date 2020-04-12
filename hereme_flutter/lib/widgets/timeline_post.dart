import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import '../constants.dart';

class TimelinePost extends StatefulWidget {
  final String currentUserId = currentUser.uid;
  final String profileImageUrl;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;
  final Map likes;

  TimelinePost({
    this.photoUrl,
    this.profileImageUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.likes,
  });

  factory TimelinePost.fromDocument(DocumentSnapshot doc) {
    return TimelinePost(
      photoUrl: doc['photoUrl'] ?? '',
      profileImageUrl: doc['profileImageUrl'] ?? '',
      uid: doc['uid'] ?? '',
      title: doc['title'] ?? '',
      creationDate: doc['creationDate'] ?? 0,
      id: doc['id'] ?? '',
      type: doc['type'] ?? '',
      likes: doc['likes'] ?? {},
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _TimelinePostState createState() => _TimelinePostState(
      photoUrl: this.photoUrl,
      profileImageUrl: this.profileImageUrl,
      uid: this.uid,
      title: this.title,
      creationDate: this.creationDate,
      id: this.id,
      type: this.type,
      likes: this.likes,
  );
}

class _TimelinePostState extends State<TimelinePost> {
  final String currentUserId = currentUser.uid;
  final String profileImageUrl;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;

  int likeCount;
  Map likes;
  bool isLiked;

  _TimelinePostState({
    this.photoUrl,
    this.profileImageUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.likes,
  });

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': false});
      timelineRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': false});
      setState(() {
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': true});
      timelineRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  String getLikeCount(likes) {
    if (likes == null) {
      return '';
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count++;
      }
    });
    return count == 0
        ? '0'
        : NumberFormat.compact().format(count);
  }

  buildPhotoPost(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => print('settings'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: title,
                            style: kDefaultTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      date(),
                      style: kDefaultTextStyle.copyWith(
                          fontSize: 12.0, color: kColorLightGray),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: Container(
                  width: 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(
                            !isLiked
                                ? FontAwesomeIcons.heart
                                : FontAwesomeIcons.solidHeart,
                            color: !isLiked ? kColorLightGray : kColorRed,
                            size: 16.0),
                        onTap: () => handleLikePost(),
                      ),
                      uid == currentUserId ? Text(
                        '$likeCount',
                        style: kDefaultTextStyle.copyWith(
                            color: !isLiked ? kColorLightGray : kColorRed,
                            fontSize: 12.0),
                      ) : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return buildPhotoPost(context);
  }
}
