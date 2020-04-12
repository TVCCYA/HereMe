import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
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
          brightness: Brightness.light,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Text(
            'Activity',
            style: kAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: kColorBlack71, size: 20),
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
            child: Column(
              children: <Widget>[
                ExpansionTile(
                  backgroundColor: Colors.transparent,
                  initiallyExpanded: true,
                  title: ReusableSectionLabel('Knocks', left: 0.0),
                  children: <Widget>[
                    ReusableFetchFutureKnocks(
                      collection: 'receivedKnockFrom',
                      title: 'Received',
                      circleColor: kColorGreen,
                      onTap: () => print('to received knocks'),
                    ),
                    ReusableFetchFutureKnocks(
                      collection: 'sentKnockTo',
                      title: 'Sent',
                      circleColor: kColorBlue,
                      onTap: () => print('to sent knocks'),
                    )
                  ],
                ),
                ExpansionTile(
                  backgroundColor: Colors.transparent,
                  initiallyExpanded: true,
                  title: ReusableSectionLabel('Page Liked By', left: 0.0),
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
                        final followers = snapshot.data.documents;
                        List<FollowerTile> displayedFollowers = [];
                        for (var user in followers) {
                          final String uid = user.documentID;
                          final int creationDate = user.data['creationDate'];

                          final follower = FollowerTile(
                            uid: uid,
                            onTap: () => print('go to profile'),
                            creationDate: creationDate ?? 0,
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
                                  child: TopProfileHeaderButton(
                                    text: 'View All',
                                    onPressed: () => print('view all followers'),
                                    width: 40,
                                    backgroundColor: Colors.transparent,
                                    textColor: kColorLightGray,
                                    splashColor: kColorExtraLightGray,
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
                  title: ReusableSectionLabel('Posts Liked By', left: 0.0),
                  children: <Widget>[
//                    FutureBuilder(
//                      future: updateRef
//                          .document(currentUser.uid)
//                          .collection('posts')
//                          .getDocuments(),
//                      builder: (context, snapshot) {
//                        if (!snapshot.hasData) {
//                          return circularProgress();
//                        }
//                        final posts = snapshot.data.documents;
//                        if (posts.isNotEmpty) {
//                          for (var post in posts) {
//                            return FutureBuilder(
//                              future: updateRef
//                                  .document(currentUser.uid)
//                                  .collection('posts')
//                                  .document(post.documentID)
//                                  .collection('likedBy')
//                                  .getDocuments(),
//                              builder: (context, snapshot) {
//                                if (!snapshot.hasData) {
//                                  return circularProgress();
//                                }
//
//                              },
//                            );
//                          }
//                          return SizedBox();
//                        }
//                        return SizedBox();
//                      },
//                    )
                  ],
                ),
                ExpansionTile(
                  backgroundColor: Colors.transparent,
                  initiallyExpanded: true,
                  title: ReusableSectionLabel('Live Chat Invites', left: 0.0),
                ),
              ],
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
        final knocks = snapshot.data.documents;
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
            onTap: onTap,
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
            ));
      },
    );
  }
}

class FollowerTile extends StatefulWidget {
  final String uid;
  final Function onTap;
  final int creationDate;
  FollowerTile({@required this.uid, this.onTap, this.creationDate});
  @override
  _FollowerTileState createState() => _FollowerTileState(
        uid: this.uid,
        onTap: this.onTap,
        creationDate: this.creationDate,
      );
}

class _FollowerTileState extends State<FollowerTile> {
  final String uid;
  final Function onTap;
  final int creationDate;
  _FollowerTileState({@required this.uid, this.onTap, this.creationDate});

  String username = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _getUserPageData();
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
    return Padding(
      padding: EdgeInsets.only(left: 4.0),
      child: ListTile(
        dense: true,
        title: Text(
          username,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: kDefaultTextStyle,
        ),
        subtitle: Text(
          creationDate != 0 ? date() : 'a long time ago',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: kDefaultTextStyle.copyWith(
            fontSize: 12.0,
            color: kColorLightGray,
          ),
        ),
        leading: cachedUserResultImage(profileImageUrl, 45, true),
        onTap: _goToProfile,
        trailing: Icon(
          Icons.chevron_right,
          size: 24,
          color: kColorLightGray,
        ),
      ),
    );
  }
}

class PostLike extends StatefulWidget {
  final String uid;
  final Function onTap;
  final int creationDate;
  PostLike({@required this.uid, this.onTap, this.creationDate});
  @override
  _PostLikeState createState() => _PostLikeState(
    uid: this.uid,
    onTap: this.onTap,
    creationDate: this.creationDate,
  );
}

class _PostLikeState extends State<PostLike> {
  final String uid;
  final Function onTap;
  final int creationDate;
  _PostLikeState({@required this.uid, this.onTap, this.creationDate});

  String username = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _getUserPageData();
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
    return Container();
  }
}


