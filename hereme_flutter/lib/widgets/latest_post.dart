import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import '../constants.dart';

final reportedPostsRef = Firestore.instance.collection('reportedPosts');

class LatestPost extends StatefulWidget {
  final String currentUserUid = currentUser.uid;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;
  final String displayName;
  final dynamic likes;
  final String profileImageUrl;
  final String videoUrl;
  final bool isHome;

  LatestPost({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.displayName,
    this.likes,
    this.profileImageUrl,
    this.videoUrl,
    this.isHome = true,
  });

  factory LatestPost.fromDocument(DocumentSnapshot doc) {
    return LatestPost(
      photoUrl: doc['photoUrl'] ?? '',
      creationDate: doc['creationDate'] ?? 0,
      id: doc['id'] ?? '',
      likes: doc['likes'] ?? {},
      title: doc['title'] ?? '',
      type: doc['type'] ?? '',
      uid: doc['uid'] ?? '',
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
  _LatestPostState createState() => _LatestPostState(
    photoUrl: this.photoUrl,
    uid: this.uid,
    displayName: this.displayName,
    title: this.title,
    creationDate: this.creationDate,
    id: this.id,
    likes: this.likes,
    type: this.type,
    likeCount: getLikeCount(likes),
    profileImageUrl: this.profileImageUrl,
    isHome: this.isHome,
  );
}

class _LatestPostState extends State<LatestPost> {
  final String currentUserUid = currentUser.uid;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;
  final String displayName;
  final String profileImageUrl;
  final String videoUrl;
  final bool isHome;

  Map likes;
  bool isLiked;
  int likeCount;
  int width = 45;

  _LatestPostState({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.displayName,
    this.likes,
    this.likeCount,
    this.profileImageUrl,
    this.videoUrl,
    this.isHome,
  });

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  settingsActionSheet(BuildContext context, bool isPhotoPost) {
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
                      .child('latest_images/$uid/$id')
                      .delete();
                }
                kHandleRemoveDataAtId(id, uid, 'latest', 'posts');
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
            _reasonToReport(context);
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

  _reasonToReport(BuildContext context) {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Spam');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.angry,
        title: 'Innappropriate',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Innappropriate');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportUser(BuildContext context, String reason) {
    bool canReport = uid != null;
    canReport
        ? reportedPostsRef.document(uid).setData({
      'uid': uid,
      'displayName': displayName,
      'reason': reason,
      'reportedByUid': currentUser.uid,
    }).whenComplete(() {
      kShowAlert(
        context: context,
        title: 'Successfully Reported',
        desc: 'Thank you for making Spred a better place',
        buttonText: 'Dismiss',
        onPressed: () => Navigator.pop(context),
        color: kColorBlue,
      );
    })
        : kShowAlert(
      context: context,
      title: 'Whoops',
      desc: 'Unable to report at this time',
      buttonText: 'Try Again',
      onPressed: () => Navigator.pop(context),
      color: kColorRed,
    );
  }

  _goToUserProfile(BuildContext context) {
    if (uid != null) {
      bool isCurrentUser = currentUserUid == uid;
      User user = User(uid: uid);
      UserResult result = UserResult(
          user: user, locationLabel: isCurrentUser ? 'Here' : 'Nearby');
      result.toProfile(context);
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserUid] == true;
    if (_isLiked) {
      latestRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': false});
      
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserUid] = false;
      });
    } else if (!_isLiked) {
      latestRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': true});

      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserUid] = true;
      });
    }
  }

  createLikedPostsOnActivity() {
    activityRef.document(currentUserUid).collection('likedPosts').document(id).setData({'uid': uid});
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserUid != uid;
    if (isNotPostOwner) {
      activityRef
          .document(uid)
          .collection('feedItems')
          .document()
          .setData({
        'creationDate': DateTime.now().millisecondsSinceEpoch,
        'postId': id,
        'postType': type,
        'type': 'like',
        'uid': currentUserUid,
      });
      removeFifthSameLikedPost();
      removeEleventhLikedPost();
      createLikedPostsOnActivity();
    }
  }

  removeFifthSameLikedPost() {
    List<int> creationDates = [];
    final ref = activityRef.document(uid).collection('feedItems');

    ref
        .where('postId', isEqualTo: id)
        .getDocuments()
        .then((snapshot) {
          if (snapshot.documents.length > 4) {
            snapshot.documents.forEach((doc) {
              final int creationDate = doc.data['creationDate'];
              creationDates.add(creationDate);
            });
            creationDates.sort((p1, p2) {
              return p2.compareTo(p1);
            });
            ref
                .where('creationDate', isEqualTo: creationDates.last)
                .getDocuments()
                .then((snapshot) {
              snapshot.documents.forEach((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                }
              });
            });
          }
    });
  }

  removeEleventhLikedPost() {
    List<int> creationDates = [];
    final ref = activityRef.document(uid).collection('feedItems');
    ref
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.length > 10) {
        snapshot.documents.forEach((doc) {
          final int creationDate = doc.data['creationDate'];
          creationDates.add(creationDate);
        });
        creationDates.sort((p1, p2) {
          return p2.compareTo(p1);
        });
        ref
            .where('creationDate', isEqualTo: creationDates.last)
            .getDocuments()
            .then((snapshot) {
          snapshot.documents.forEach((doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          });
        });
      }
    });
  }

  removeLikeFromActivityFeed()  {
    activityRef
        .document(uid)
        .collection('feedItems')
        .where('postId', isEqualTo: id)
        .where('uid', isEqualTo: currentUserUid)
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
    removeLikedPostFromActivity();
  }

  removeLikedPostFromActivity() {
    activityRef.document(currentUserUid).collection('likedPosts').document(id).delete();
  }

  buildTextPost() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: GestureDetector(
        onTap: () => settingsActionSheet(context, false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _goToUserProfile(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  profileImageUrl != null
                      ? cachedUserResultImage(profileImageUrl, 30, false)
                      : SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      displayName,
                      style: kAppBarTextStyle.copyWith(
                          fontSize: 14.0, color: kColorLightGray),
                    ),
                  ),
                  Text(
                    ' • ${date()}',
                    style: kDefaultTextStyle.copyWith(
                        fontSize: 12.0, color: kColorLightGray),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: screenWidth - width,
                      child: Padding(
                        padding: EdgeInsets.only(left: 38.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: kDefaultTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        uid == currentUserUid
                            ? Text(
                          '$likeCount',
                          style: kDefaultTextStyle.copyWith(
                              color: !isLiked
                                  ? kColorLightGray
                                  : kColorRed,
                              fontSize: 12.0),
                        )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0, left: 30.0),
              child: Container(
                height: 1.0,
                width: screenWidth,
                color: kColorExtraLightGray,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildNewPhotoPost() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => _goToUserProfile(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                profileImageUrl != null
                    ? cachedUserResultImage(profileImageUrl, 30, false)
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    displayName,
                    style: kAppBarTextStyle.copyWith(
                        fontSize: 14.0, color: kColorLightGray),
                  ),
                ),
                Text(
                  ' • ${date()}',
                  style: kDefaultTextStyle.copyWith(
                      fontSize: 12.0, color: kColorLightGray),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: screenWidth - width,
                    child: Padding(
                      padding: EdgeInsets.only(left: 38.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          title != '' ? Text(
                            title,
                            style: kDefaultTextStyle,
                          ) : SizedBox(),
                          SizedBox(height: 4.0),
                          cachedRoundedCornerImage(photoUrl, screenWidth),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      uid == currentUserUid
                          ? Text(
                        '$likeCount',
                        style: kDefaultTextStyle.copyWith(
                            color: !isLiked
                                ? kColorLightGray
                                : kColorRed,
                            fontSize: 12.0),
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0, left: 30.0),
            child: Container(
              height: 1.0,
              width: screenWidth,
              color: kColorExtraLightGray,
            ),
          )
        ],
      ),
    );
  }

  buildPhotoPost() {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            height: screenHeight / 3,
            width: screenHeight / 2,
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: profileImageUrl != null
              ? GestureDetector(
              child: cachedUserResultImage(profileImageUrl, 50, true),
              onTap: () => _goToUserProfile(context))
              : SizedBox(),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0 * 2),
                border: Border.all(
                  width: 2,
                  color: kColorOffWhite,
                ),
              ),
              child: Icon(
                  !isLiked
                      ? FontAwesomeIcons.heart
                      : FontAwesomeIcons.solidHeart,
                  color: !isLiked ? kColorLightGray : kColorRed,
                  size: 15.0),
            ),
            onTap: () => handleLikePost(),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 54.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  displayName,
                  style: kAppBarTextStyle.copyWith(
                    fontSize: 14.0,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 3.0,
                        color: kColorBlack62,
                      ),
                    ],
                  ),
                ),
                Text(
                  ' • ${date()}',
                  style: kAppBarTextStyle.copyWith(
                    fontSize: 14.0,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 3.0,
                        color: kColorBlack62,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  buildViewAllPhotoPost() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  determineFeedItem(double screenWidth) {
    if (isHome) {
      if (type == 'text') {
        return buildTextPost();
      } else if (type == 'photo') {
        return buildNewPhotoPost();
      } else {
        return SizedBox();
      }
    } else {
      return buildViewAllPhotoPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    isLiked = likes[currentUserUid] == true;
    final double screenWidth = MediaQuery.of(context).size.width;
    return determineFeedItem(screenWidth);
  }
}

// ignore: must_be_immutable
class ProfileLatestPost extends StatelessWidget {
  final String currentUserUid = currentUser.uid;
  final String photoUrl;
  final String uid;
  final String title;
  final int creationDate;
  final String id;
  final String type;
  final String displayName;
  final String profileImageUrl;
  final String videoUrl;
  final int red;
  final int green;
  final int blue;

  Map likes;
  bool isLiked;
  int width = 45;

  ProfileLatestPost({
    this.photoUrl,
    this.uid,
    this.title,
    this.creationDate,
    this.id,
    this.type,
    this.displayName,
    this.likes,
    this.profileImageUrl,
    this.videoUrl,
    this.red,
    this.green,
    this.blue
  });

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

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  settingsActionSheet(BuildContext context, bool isPhotoPost) {
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
                      .child('latest_images/$uid/$id')
                      .delete();
                }
                kHandleRemoveDataAtId(id, uid, 'latest', 'posts');
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
            _reasonToReport(context);
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

  _reasonToReport(BuildContext context) {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Spam');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.angry,
        title: 'Innappropriate',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Innappropriate');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportUser(BuildContext context, String reason) {
    bool canReport = uid != null;
    canReport
        ? reportedPostsRef.document(uid).setData({
      'uid': uid,
      'displayName': displayName,
      'reason': reason,
      'reportedByUid': currentUser.uid,
    }).whenComplete(() {
      kShowAlert(
        context: context,
        title: 'Successfully Reported',
        desc: 'Thank you for making Spred a better place',
        buttonText: 'Dismiss',
        onPressed: () => Navigator.pop(context),
        color: kColorBlue,
      );
    })
        : kShowAlert(
      context: context,
      title: 'Whoops',
      desc: 'Unable to report at this time',
      buttonText: 'Try Again',
      onPressed: () => Navigator.pop(context),
      color: kColorRed,
    );
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserUid] == true;
    if (_isLiked) {
      latestRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': false}); 
      
      removeLikeFromActivityFeed();
      isLiked = false;
      likes[currentUserUid] = false;
    } else if (!_isLiked) {
      latestRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': true});
      
      addLikeToActivityFeed();
      isLiked = true;
      likes[currentUserUid] = true;
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserUid != uid;
    if (isNotPostOwner) {
      activityRef
          .document(uid)
          .collection('feedItems')
          .document()
          .setData({
        'creationDate': DateTime.now().millisecondsSinceEpoch,
        'postId': id,
        'postType': type,
        'type': 'like',
        'uid': currentUserUid,
      });
      removeFifthSameLikedPost();
      removeEleventhLikedPost();
      createLikedPostsOnActivity();
    }
  }

  createLikedPostsOnActivity() {
    activityRef.document(currentUserUid).collection('likedPosts').document(id).setData({'uid': uid});
  }

  removeFifthSameLikedPost() {
    List<int> creationDates = [];
    final ref = activityRef.document(uid).collection('feedItems');

    ref
        .where('postId', isEqualTo: id)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.length > 4) {
        snapshot.documents.forEach((doc) {
          final int creationDate = doc.data['creationDate'];
          creationDates.add(creationDate);
        });
        creationDates.sort((p1, p2) {
          return p2.compareTo(p1);
        });
        ref
            .where('creationDate', isEqualTo: creationDates.last)
            .getDocuments()
            .then((snapshot) {
          snapshot.documents.forEach((doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          });
        });
      }
    });
  }

  removeEleventhLikedPost() {
    List<int> creationDates = [];
    final ref = activityRef.document(uid).collection('feedItems');
    ref
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.length > 10) {
        snapshot.documents.forEach((doc) {
          final int creationDate = doc.data['creationDate'];
          creationDates.add(creationDate);
        });
        creationDates.sort((p1, p2) {
          return p2.compareTo(p1);
        });
        ref
            .where('creationDate', isEqualTo: creationDates.last)
            .getDocuments()
            .then((snapshot) {
          snapshot.documents.forEach((doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          });
        });
      }
    });
  }

  removeLikeFromActivityFeed()  {
    activityRef
        .document(uid)
        .collection('feedItems')
        .where('postId', isEqualTo: id)
          .where('uid', isEqualTo: currentUserUid)
          .getDocuments()
          .then((snapshot) {
        snapshot.documents.forEach((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
    });
    removeLikedPostFromActivity();
  }

  removeLikedPostFromActivity() {
    activityRef.document(currentUserUid).collection('likedPosts').document(id).delete();
  }

  buildTextPost(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: GestureDetector(
        onTap: () => settingsActionSheet(context, false),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 4.0, left: 4.0),
              child: Container(
                width: screenWidth - width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$displayName: ',
                            style: kDefaultTextStyle.copyWith(
                                color: Color.fromRGBO(
                                    red ?? 71,
                                    green ?? 71,
                                    blue ?? 71,
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
                    Text(
                      date(),
                      style: kDefaultTextStyle.copyWith(
                          fontSize: 12.0, color: kColorLightGray),
                    ),
                  ],
                ),
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
                    uid == currentUserUid
                        ? Text(
                      '${getLikeCount(likes)}',
                      style: kDefaultTextStyle.copyWith(
                          color: !isLiked ? kColorLightGray : kColorRed,
                          fontSize: 12.0),
                    )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildPhotoPost(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => settingsActionSheet(context, true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Container(
                    width: screenWidth - width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$displayName: ',
                                style: kDefaultTextStyle.copyWith(
                                    color: Color.fromRGBO(
                                        red ?? 71,
                                        green ?? 71,
                                        blue ?? 71,
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
                        Text(
                          date(),
                          style: kDefaultTextStyle.copyWith(
                              fontSize: 12.0, color: kColorLightGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: screenWidth - width,
                    child: Padding(
                      padding: EdgeInsets.only(left: 38.0),
                      child: cachedRoundedCornerImage(photoUrl, screenWidth),
                    ),
                  ),
                ],
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
                      uid == currentUserUid
                          ? Text(
                        '${getLikeCount(likes)}',
                        style: kDefaultTextStyle.copyWith(
                            color: !isLiked
                                ? kColorLightGray
                                : kColorRed,
                            fontSize: 12.0),
                      ) : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildLinkPost() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$displayName: ',
                    style: kDefaultTextStyle.copyWith(
                        color: Color.fromRGBO(
                            red ?? 71,
                            green ?? 71,
                            blue ?? 71,
                            1.0),
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '* linked a new account *',
                    style:
                    kDefaultTextStyle.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Text(
              ' ' + date(),
              style: kDefaultTextStyle.copyWith(
                  fontSize: 12.0, color: kColorLightGray),
            ),
          ],
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
    isLiked = likes[currentUserUid] == true;
    final double screenWidth = MediaQuery.of(context).size.width;
    return determineFeedItem(context, screenWidth);
  }
}

