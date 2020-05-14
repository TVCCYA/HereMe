import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/notifications/all_followers.dart';
import 'package:hereme_flutter/notifications/knocks/received_knocks.dart';
import 'package:hereme_flutter/latest/post_full_screen.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/widgets/latest_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Text(
            'Activity',
            style: kAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: kColorBlack62, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: <Widget>[
                  ExpansionTile(
                    backgroundColor: Colors.transparent,
                    initiallyExpanded: true,
                    title: ReusableHeaderLabel('Knocks',
                        left: 0.0, top: 0.0, bottom: 0.0),
                    children: <Widget>[
                      ReusableFetchFutureKnocks(
                        collection: 'receivedKnockFrom',
                        title: 'Received',
                        circleColor: kColorGreen,
                      ),
                    ],
                  ),
                  ExpansionTile(
                    backgroundColor: Colors.transparent,
                    initiallyExpanded: true,
                    title: ReusableHeaderLabel('Page Liked By',
                        left: 0.0, top: 0.0, bottom: 0.0),
                    children: <Widget>[
                      FutureBuilder(
                        future: followersRef
                            .document(currentUser.uid)
                            .collection('users')
                            .orderBy('creationDate', descending: true)
                            .limit(5)
                            .getDocuments(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return circularProgress();
                          }
                          final List<DocumentSnapshot> followers =
                              snapshot.data.documents;
                          List<FollowerTile> displayedFollowers = [];
                          for (var user in followers) {
                            final String uid = user.documentID;
                            final int creationDate = user.data['creationDate'];

                            final follower = FollowerTile(
                              uid: uid,
                              creationDate: creationDate ?? 0,
                              showDate: true,
                              isUserLikes: false,
                            );

                            displayedFollowers.add(follower);
                          }
                          if (displayedFollowers.isNotEmpty) {
                            return Column(
                              children: <Widget>[
                                Column(
                                  children: displayedFollowers,
                                ),
                                Center(
                                  child: Container(
                                    height: 30,
                                    child: ReusableRoundedCornerButton(
                                      text: 'View All',
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AllFollows())),
                                      width: 40,
                                      backgroundColor: Colors.transparent,
                                      textColor: kColorLightGray,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                  ExpansionTile(
                    backgroundColor: Colors.transparent,
                    initiallyExpanded: true,
                    title: ReusableHeaderLabel('Posts Liked By',
                        left: 0.0, top: 0.0, bottom: 0.0),
                    children: <Widget>[
                      FutureBuilder(
                        future: activityRef
                            .document(currentUser.uid)
                            .collection('feedItems')
                            .where('type', isEqualTo: 'like')
                            .getDocuments(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return circularProgress();
                          }
                          final List<DocumentSnapshot> likes =
                              snapshot.data.documents;
                          List<PostLike> displayedLikes = [];
                          for (var like in likes) {
                            final int creationDate = like.data['creationDate'];
                            final String postId = like.data['postId'];
                            final String postType = like.data['postType'];
                            final String type = like.data['type'];
                            final String uid = like.data['uid'];

                            final post = PostLike(
                              creationDate: creationDate,
                              postId: postId,
                              postType: postType,
                              type: type,
                              uid: uid,
                            );
                            displayedLikes.add(post);
                            displayedLikes.sort((p1, p2) {
                              return p2.creationDate.compareTo(p1.creationDate);
                            });
                          }
                          if (displayedLikes.isNotEmpty) {
                            return Column(children: displayedLikes);
                          }
                          return SizedBox();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReusableFetchFutureKnocks extends StatelessWidget {
  final String collection;
  final String title;
  final Color circleColor;
  final Function onTap;

  ReusableFetchFutureKnocks(
      {@required this.collection, this.title, this.circleColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: knocksRef
          .document(currentUser.uid)
          .collection(collection)
          .getDocuments(),
      builder: (context, snapshot) {
        var count;
        if (!snapshot.hasData) {
          count = 0;
          return SizedBox();
        }
        final List<DocumentSnapshot> knocks = snapshot.data.documents;
        count = knocks.length;
        return ListTile(
          dense: true,
          title: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: kDefaultTextStyle,
            ),
          ),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReceivedKnocks())),
          trailing: Container(
            width: 90,
            child: Padding(
              padding: EdgeInsets.only(right: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: circleColor,
                    ),
                  ),
                  Text(
                    '  ${NumberFormat.compact().format(count)}',
                    style: kDefaultTextStyle.copyWith(color: kColorLightGray),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FollowerTile extends StatefulWidget {
  final String uid;
  final int creationDate;
  final bool showDate;
  final bool isUserLikes;
  FollowerTile(
      {@required this.uid, this.creationDate, this.showDate, this.isUserLikes});
  @override
  _FollowerTileState createState() => _FollowerTileState(
        uid: this.uid,
        creationDate: this.creationDate,
        showDate: this.showDate,
        isUserLikes: this.isUserLikes,
      );
}

class _FollowerTileState extends State<FollowerTile> {
  final String uid;
  final int creationDate;
  final bool showDate;
  final bool isUserLikes;
  _FollowerTileState(
      {@required this.uid, this.creationDate, this.showDate, this.isUserLikes});

  String username = '';
  String profileImageUrl = '';
  bool _isFollowing = false;
  bool _beingFollowed = true;

  @override
  void initState() {
    super.initState();
    _getUserPageData();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(uid)
        .collection('users')
        .document(currentUser.uid)
        .get();
    setState(() {
      _isFollowing = doc.exists;
    });
  }

  _followUser() {
    print('following');
    if (this.mounted) {
      setState(() {
        _isFollowing = true;
      });
    }

    followersRef
        .document(uid)
        .collection('users')
        .document(currentUser.uid)
        .setData({'creationDate': DateTime.now().millisecondsSinceEpoch});

    followingRef
        .document(currentUser.uid)
        .collection('users')
        .document(uid)
        .setData({});
  }

  _unfollowUser() {
    print('unfollow');
    if (this.mounted) {
      setState(() {
        _isFollowing = false;
      });
    }

    followersRef
        .document(uid)
        .collection('users')
        .document(currentUser.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUser.uid)
        .collection('users')
        .document(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  confirmRemove() {
    kShowAlertMultiButtons(
      context: context,
      title: 'Remove?',
      desc:
          '$username will not be notified that they were removed from your page likes',
      color1: kColorRed,
      color2: kColorLightGray,
      buttonText1: 'Remove',
      buttonText2: 'Cancel',
      onPressed1: () {
        removeFollower();
        Navigator.pop(context);
      },
      onPressed2: () => Navigator.pop(context),
    );
  }

  removeFollower() {
    if (this.mounted) {
      setState(() {
        _beingFollowed = false;
      });
    }
    followersRef
        .document(currentUser.uid)
        .collection('users')
        .document(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(uid)
        .collection('users')
        .document(currentUser.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _getUserPageData() {
    usersRef.document(uid).get().then((doc) {
      User user = User.fromDocument(doc);
      if (this.mounted)
        setState(() {
          username = user.username;
          profileImageUrl = user.profileImageUrl;
        });
    });
  }

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  _goToProfile() {
    User user = User(uid: uid);
    UserResult result = UserResult(user: user, locationLabel: 'Around');
    result.toProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0, right: 4.0),
      child: Container(
        height: 50,
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: _goToProfile,
              child: Row(
                children: <Widget>[
                  cachedUserResultImage(profileImageUrl, 45, true),
                  SizedBox(width: 12.0),
                  Container(
                    width: screenWidth / 1.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          username,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                        ),
                        showDate
                            ? Text(
                                creationDate != 0 ? date() : 'a long time ago',
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: kDefaultTextStyle.copyWith(
                                  fontSize: 12.0,
                                  color: kColorLightGray,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            showDate || isUserLikes
                ? IconButton(
                    splashColor: Colors.transparent,
                    iconSize: 16,
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(
                        _isFollowing
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        color: _isFollowing ? kColorRed : kColorLightGray),
                    onPressed: () =>
                        _isFollowing ? _unfollowUser() : _followUser(),
                  )
                : IconButton(
                    splashColor: Colors.transparent,
                    iconSize: 16,
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(
                        _beingFollowed
                            ? FontAwesomeIcons.times
                            : FontAwesomeIcons.minus,
                        color: kColorLightGray),
                    onPressed: () =>
                        _beingFollowed ? confirmRemove() : print('do nothing'),
                  ),
          ],
        ),
      ),
    );
  }
}

class PostLike extends StatefulWidget {
  final int creationDate;
  final String postId;
  final String postType;
  final String type;
  final String uid;
  PostLike(
      {this.creationDate,
      @required this.postId,
      this.postType,
      this.type,
      this.uid});
  @override
  _PostLikeState createState() => _PostLikeState(
      creationDate: this.creationDate,
      postId: this.postId,
      postType: this.postType,
      type: this.type,
      uid: this.uid);
}

class _PostLikeState extends State<PostLike> {
  final int creationDate;
  final String postId;
  final String postType;
  final String type;
  final String uid;
  _PostLikeState(
      {this.creationDate,
      @required this.postId,
      this.postType,
      this.type,
      this.uid});

  String username = '';
  String displayName = '';
  String profileImageUrl = '';
  String photoUrl = '';
  String title = '';
  Map<dynamic, dynamic> likes = {};

  @override
  void initState() {
    super.initState();
    _getUserPageData();
    _getLatestPostData();
  }

  _getUserPageData() {
    usersRef.document(uid).get().then((doc) {
      User user = User.fromDocument(doc);
      if (this.mounted)
        setState(() {
          username = user.username;
          displayName = user.displayName;
          profileImageUrl = user.profileImageUrl;
        });
    });
  }

  _getLatestPostData() {
    latestRef
        .document(currentUser.uid)
        .collection('posts')
        .document(postId)
        .get()
        .then((doc) {
      LatestPost post = LatestPost.fromDocument(doc);
      if (this.mounted)
        setState(() {
          photoUrl = post.photoUrl;
          title = post.title;
          likes = post.likes;
        });
    });
  }

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  _goToProfile() {
    User user = User(uid: uid);
    UserResult result = UserResult(user: user, locationLabel: 'Around');
    result.toProfile(context);
  }

  _goToPost() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostFullScreen(
                  postId: postId,
                  uid: currentUser.uid,
                  title: title,
                  displayName: currentUser.displayName,
                  username: currentUser.username,
                  photoUrl: photoUrl,
                  creationDate: creationDate,
                  type: postType,
                  profileImageUrl: currentUser.profileImageUrl,
                  likes: likes,
                )));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                    onTap: () => _goToProfile(),
                    child: cachedUserResultImage(profileImageUrl, 45, true)),
                SizedBox(width: 12.0),
                Container(
                  width:
                      photoUrl != '' ? screenWidth / 1.95 : screenWidth / 1.25,
                  child: GestureDetector(
                    onTap: () => _goToPost(),
                    child: RichText(
                      maxLines: 2,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${username.trim()} ',
                            style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          ),
                          photoUrl != ''
                              ? TextSpan(
                                  text: 'liked your photo',
                                  style: kDefaultTextStyle,
                                )
                              : TextSpan(
                                  text: "liked your post: '$title'",
                                  style: kDefaultTextStyle,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            photoUrl != ''
                ? GestureDetector(
                    onTap: () => _goToPost(),
                    child: cachedRoundedCornerImage(photoUrl, 45, radius: 5),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
//    return Padding(
//      padding: EdgeInsets.only(left: 4.0),
//      child: ListTile(
//          dense: true,
//          title: RichText(
//            text: TextSpan(
//              children: [
//                TextSpan(
//                  text: '$username ',
//                  style: kAppBarTextStyle.copyWith(fontSize: 16.0),
//                ),
//                photoUrl != ''
//                    ? TextSpan(
//                        text: 'liked your photo',
//                        style: kDefaultTextStyle,
//                      )
//                    : TextSpan(
//                        text: "liked your post: '$title'",
//                        style: kDefaultTextStyle,
//                      ),
//              ],
//            ),
//          ),
//          subtitle: Text(
//            creationDate != 0 ? date() : 'a long time ago',
//            overflow: TextOverflow.fade,
//            softWrap: false,
//            style: kDefaultTextStyle.copyWith(
//              fontSize: 12.0,
//              color: kColorLightGray,
//            ),
//          ),
//          leading: cachedUserResultImage(profileImageUrl, 45, true),
//          onTap: _goToProfile,
//          trailing: photoUrl != ''
//              ? cachedRoundedCornerImage(photoUrl, 45, radius: 5)
//              : SizedBox()),
//    );
  }
}
