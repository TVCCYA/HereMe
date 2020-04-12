import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class ProfileImageFullScreen extends StatelessWidget {
  final String profileImageUrl;
  ProfileImageFullScreen(this.profileImageUrl);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Dismissible(
        resizeDuration: Duration(milliseconds: 1),
        direction: DismissDirection.vertical,
        key: Key('key'),
        onDismissed: (_) => Navigator.pop(context),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: PinchZoomImage(
                  zoomedBackgroundColor: Colors.black,
                  hideStatusBarWhileZooming: false,
                  image: CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    height: screenHeight,
                    width: screenWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                EdgeInsets.only(top: 8.0, left: 24.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(FontAwesomeIcons.times,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenLatestPhoto extends StatefulWidget {
  final int index;
  final List<dynamic> displayedUpdates;
  FullScreenLatestPhoto({this.index, this.displayedUpdates});
  @override
  _FullScreenLatestPhotoState createState() => _FullScreenLatestPhotoState(
      index: this.index, displayedUpdates: this.displayedUpdates);
}

class _FullScreenLatestPhotoState extends State<FullScreenLatestPhoto> {
  final int index;
  final List<dynamic> displayedUpdates;
  _FullScreenLatestPhotoState({this.index, this.displayedUpdates});
  bool showTitle = true;

  @override
  void initState() {
    super.initState();
    print(index);
  }

  _imageTapped() {
    if (showTitle) {
      if (this.mounted)
        setState(() {
          showTitle = false;
        });
    } else {
      if (this.mounted)
        setState(() {
          showTitle = true;
        });
    }
  }

  settingsActionSheet(BuildContext context, String uid, String id, String displayName) {
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
                FirebaseStorage.instance
                    .ref()
                    .child('update_images/$uid/$id')
                    .delete().whenComplete(() {
                  kHandleRemoveDataAtId(id, uid, 'update', 'posts');
                  Navigator.pop(context);
                });
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
            _reasonToReport(context, uid, displayName);
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

  _reasonToReport(BuildContext context, String uid, String displayName) {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Spam', uid, displayName);
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
          _reportUser(context, 'Innappropriate', uid, displayName);
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

  _reportUser(BuildContext context, String reason, String uid, String displayName) {
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

  _goToUserProfile(BuildContext context, String currentUserUid, String uid) {
    if (uid != null) {
      bool isCurrentUser = currentUserUid == uid;
      User user = User(uid: uid);
      UserResult result = UserResult(
          user: user, locationLabel: isCurrentUser ? 'Here' : 'Nearby');
      result.toProfile(context);
    }
  }

  String date(int creationDate) {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  handleLikePost(
      {String currentUserUid, Map likes, String uid, String id, bool isLiked,
      String type, String photoUrl, String title}) {
    bool _isLiked = likes[currentUserUid] == true;
    if (_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': false});

      DocumentReference timeline = timelineRef
          .document(currentUserUid)
          .collection('timelinePosts')
          .document(id);
      timeline.get().then((doc) {
        if (doc.exists) {
          timeline.updateData({'likes.$currentUserUid': false});
        }
      });

      DocumentReference exploreRef = exploreTimelineRef.document(id);
      exploreRef.get().then((doc) {
        if (doc.exists) {
          exploreRef.updateData({'likes.$currentUserUid': false});
        }
      });
      setState(() {
        isLiked = false;
        likes[currentUserUid] = false;
      });
    } else if (!_isLiked) {
      updateRef
          .document(uid)
          .collection('posts')
          .document(id)
          .updateData({'likes.$currentUserUid': true});

      DocumentReference timeline = timelineRef
          .document(currentUserUid)
          .collection('timelinePosts')
          .document(id);
      timeline.get().then((doc) {
        if (doc.exists) {
          timeline.updateData({'likes.$currentUserUid': true});
        }
      });

      DocumentReference exploreRef = exploreTimelineRef.document(id);
      exploreRef.get().then((doc) {
        if (doc.exists) {
          exploreRef.updateData({'likes.$currentUserUid': true});
        }
      });
      addLikeToActivityFeed(uid, id, type, photoUrl, title);
      setState(() {
        isLiked = true;
        likes[currentUserUid] = true;
      });
    }
  }

  addLikeToActivityFeed(String uid, String id, String type, String photoUrl, String title) {
    bool isNotPostOwner = currentUser.uid != uid;
    if (isNotPostOwner) {
      activityRef
          .document(uid)
          .collection('feedItems')
          .document(id)
          .setData({
        'type': 'like',
        'postType': type,
        'username': currentUser.username,
        'uid': currentUser.uid,
        'profileImageUrl': currentUser.profileImageUrl,
        'id': id,
        'photoUrl': photoUrl,
        'title': title,
        'creationDate': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  buildPost(BuildContext context, int i) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.height;
    var post = displayedUpdates[i];
    bool isLiked = post.likes[post.currentUserUid] == true;
    return GestureDetector(
      onTap: () => _imageTapped(),
      child: Dismissible(
        resizeDuration: Duration(milliseconds: 1),
        direction: DismissDirection.vertical,
        key: Key('key'),
        onDismissed: (_) => Navigator.pop(context),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: PinchZoomImage(
                  zoomedBackgroundColor: Colors.black,
                  hideStatusBarWhileZooming: false,
                  image: CachedNetworkImage(
                    imageUrl: post.photoUrl,
                    height: screenHeight,
                    width: screenWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            showTitle
                ? ShowUp(
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 8.0, left: 24.0, right: 24.0),
                            child: GestureDetector(
                              onTap: () => _goToUserProfile(context, post.currentUserUid, post.uid),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        post.displayName,
                                        style: kAppBarTextStyle.copyWith(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              blurRadius: 3.0,
                                              color: kColorBlack71,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        ' • ${date(post.creationDate)}',
                                        style: kAppBarTextStyle.copyWith(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              blurRadius: 3.0,
                                              color: kColorBlack71,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => handleLikePost(
                                      currentUserUid: post.currentUserUid,
                                      likes: post.likes,
                                      uid: post.uid,
                                      id: post.id,
                                      isLiked: post.isLiked,
                                      type: post.type,
                                      photoUrl: post.photoUrl,
                                      title: post.title,
                                    ),
                                    child: Icon(
                                        !isLiked
                                            ? FontAwesomeIcons.heart
                                            : FontAwesomeIcons.solidHeart,
                                        color: !isLiked ? kColorLightGray : kColorRed,
                                        size: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 8.0, left: 24.0),
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(FontAwesomeIcons.times,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 8.0, right: 24.0),
                                    child: GestureDetector(
                                      onTap: () => settingsActionSheet(context, post.uid, post.id, post.displayName),
                                      child: Icon(FontAwesomeIcons.ellipsisH,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0, left: 24.0),
                                child: Text(
                                  post.title,
                                  style: kAppBarTextStyle.copyWith(
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                        blurRadius: 5.0,
                                        color: kColorBlack71,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        ),
//      child: CachedNetworkImage(
//        imageUrl: post.photoUrl,
//        height: screenHeight,
//        width: screenWidth,
//        fit: BoxFit.contain,
//      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: PageController(initialPage: index),
          itemCount: displayedUpdates.length,
          itemBuilder: (context, i) {
            return buildPost(context, i);
          },
        ),
      ),
    );
  }
}

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class ShowUp extends StatefulWidget {
  final Widget child;
  final int delay;

  ShowUp({@required this.child, this.delay});

  @override
  _ShowUpState createState() => _ShowUpState();
}

class _ShowUpState extends State<ShowUp> with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset = Tween<Offset>(begin: const Offset(0.0, 0.0), end: Offset.zero)
        .animate(curve);

    if (widget.delay == null) {
      _animController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
      opacity: _animController,
    );
  }
}
