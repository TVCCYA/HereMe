import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/view_all_latest_photos.dart';
import 'package:hereme_flutter/home/view_all_latest_text.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/photo_add.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../constants.dart';
import 'bottom_bar.dart';

class Explore extends StatefulWidget {
  final List<String> blockedUids;

  Explore({this.blockedUids});
  @override
  _ExploreState createState() => _ExploreState(
        blockedUids: this.blockedUids,
      );
}

class _ExploreState extends State<Explore>
    with AutomaticKeepAliveClientMixin<Explore> {
  final List<String> blockedUids;

  _ExploreState({this.blockedUids});

  bool get wantKeepAlive => true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<User> topWeeklyUsers = [];
  List<User> topAllTimeUsers = [];
  List<LatestPost> latestPosts = [];
  bool isPageLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeeklyUsers();
  }

  fetchWeeklyUsers() async {
    int count = 0;
    Future<QuerySnapshot> snapshots = usersRef
        .where('weeklyVisitsCount', isGreaterThan: 0)
        .orderBy('weeklyVisitsCount', descending: true)
        .limit(10)
        .getDocuments();
    snapshots.then((document) {
      List<User> users =
          document.documents.map((doc) => User.fromDocument(doc)).toList();
      if (this.mounted)
        setState(() {
          this.topWeeklyUsers = users;
        });
      if (users.isNotEmpty) {
        for (var user in users) {
          topUsersRef.document(user.uid).setData({}).whenComplete(() {
            print('adding weekly ${count++}');
          });
        }
      }
      getTopUsersFromFirestore(topWeeklyUsers);
      if (users.isEmpty) {
        fetchAllTimeUsers();
      }
    });
    if (this.mounted)
      setState(() {
        isPageLoading = false;
      });
  }

  fetchAllTimeUsers() async {
    int count = 0;
    Stream<QuerySnapshot> snapshots = usersRef
        .where('totalVisitsCount', isGreaterThan: 0)
        .orderBy('totalVisitsCount', descending: true)
        .limit(10)
        .snapshots();
    snapshots.listen((document) {
      List<User> users =
          document.documents.map((doc) => User.fromDocument(doc)).toList();
      if (this.mounted)
        setState(() {
          this.topAllTimeUsers = users;
        });
      if (users.isNotEmpty) {
        for (var user in users) {
          topUsersRef.document(user.uid).setData({}).whenComplete(() {
            print('adding alltime ${count++}');
          });
        }
      }
    });
    await getTopUsersFromFirestore(topAllTimeUsers);
  }

  getTopUsersFromFirestore(List<User> users) async {
    List<String> uids = [];
    List<String> uidOnFeed = [];
    final ref = topUsersRef;
    ref.getDocuments().then((snapshot) {
      for (var doc in snapshot.documents) {
        if (doc.exists) {
          uids.add(doc.documentID);
        }
      }
      for (var uid in uids) {
        for (var user in users) {
          if (users.isNotEmpty) {
            if (uid == user.uid) {
              uidOnFeed.add(uid);
            }
          }
        }
        if (!uidOnFeed.contains(uid)) {
          if (users.isNotEmpty) {
            ref.document(uid).delete();
          }
        }
      }
    });
  }

  buildWeeklyTopViewed() {
    return StreamBuilder(
      stream: usersRef
          .where('weeklyVisitsCount', isGreaterThan: 0)
          .orderBy('weeklyVisitsCount', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<User> topUsers = [];
        final users = snapshot.data.documents;
        for (var user in users) {
          final imageUrl = user.data['profileImageUrl'];
          final uid = user.data['uid'];
          final hasAccountLinked = user.data['hasAccountLinked'];
          final city = user.data['city'];
          final username = user.data['username'];

          final displayedUser = User(
            profileImageUrl: imageUrl,
            uid: uid,
            city: city,
            hasAccountLinked: hasAccountLinked,
            username: username,
          );
          if (hasAccountLinked != null &&
              hasAccountLinked &&
              !blockedUids.contains(uid)) {
            topUsers.add(displayedUser);
          }
        }
        List<GridTile> gridTiles = [];
        topUsers.forEach((user) {
          gridTiles.add(
            GridTile(
              child: UserResult(
                user: user,
                locationLabel: user.city ?? 'Around',
              ),
            ),
          );
        });
        if (topUsers.isNotEmpty && topUsers.length > 5) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ReusableHeaderLabel('Most Viewed This Week', top: 12.0),
              Container(
                height: 110,
                child: GridView.count(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  crossAxisCount: 1,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 1.0,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: gridTiles,
                ),
              ),
            ],
          );
        } else {
          return buildTotalTopViewed();
        }
      },
    );
  }

  buildTotalTopViewed() {
    return FutureBuilder(
      future: usersRef
          .orderBy('totalVisitsCount', descending: true)
          .where('totalVisitsCount', isGreaterThan: 0)
          .limit(10)
          .getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<User> topUsers = [];
        final users = snapshot.data.documents;
        for (var user in users) {
          final imageUrl = user.data['profileImageUrl'];
          final uid = user.data['uid'];
          final hasAccountLinked = user.data['hasAccountLinked'];
          final city = user.data['city'];
          final username = user.data['username'];

          final displayedUser = User(
            profileImageUrl: imageUrl,
            uid: uid,
            city: city,
            hasAccountLinked: hasAccountLinked,
            username: username,
          );
          if (hasAccountLinked != null &&
              hasAccountLinked &&
              !blockedUids.contains(uid)) {
            topUsers.add(displayedUser);
          }
        }
        List<GridTile> gridTiles = [];
        topUsers.forEach((user) {
          if (user.hasAccountLinked != null &&
              user.hasAccountLinked &&
              !blockedUids.contains(user.uid)) {
            gridTiles.add(GridTile(
                child: UserResult(user: user, locationLabel: user.city)));
          }
        });
        if (topUsers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ReusableHeaderLabel('Top Viewed All Time', top: 12.0),
              Container(
                height: 120,
                child: GridView.count(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  crossAxisCount: 1,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 1.0,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: gridTiles,
                ),
              ),
            ],
          );
        } else {
          return Container(
            height: 75.0,
            child: Center(
              child: Text(
                'Nobody To Be Displayed',
                style: kAppBarTextStyle,
              ),
            ),
          );
        }
      },
    );
  }

  getTimeline() async {
    for (var user in topWeeklyUsers) {
      QuerySnapshot snapshot =
          await updateRef.document(user.uid).collection('posts').getDocuments();
      List<LatestPost> posts = snapshot.documents
          .map((doc) => LatestPost.fromDocument(doc))
          .toList();
      for (var post in snapshot.documents) {
        final String photoUrl = post.data['photoUrl'];
        final String title = post.data['title'];
        final int creationDate = post.data['creationDate'];
        final String type = post.data['type'];
        final String id = post.data['id'];
        final dynamic likes = post.data['likes'];
        final String uid = post.data['uid'];
        final String displayName = post.data['displayName'];
        final displayedPost = LatestPost(
          photoUrl: photoUrl,
          title: title,
          creationDate: creationDate,
          type: type,
          uid: uid,
          id: id,
          displayName: displayName ?? 'name',
          likes: likes ?? {},
        );
        setState(() {
          if (!latestPosts.contains(displayedPost))
            this.latestPosts.add(displayedPost);
        });
      }
    }
  }

  buildTimeline() {
    if (latestPosts == null) {
      return circularProgress();
    } else if (latestPosts.isEmpty) {
      return Container(
        height: 50,
        width: 50,
        color: kColorBlue,
      );
    } else {
      latestPosts.sort((p1, p2) {
        return p2.creationDate.compareTo(p1.creationDate);
      });
      return Column(children: latestPosts);
    }
  }

  buildLatestPosts(
      String postType, String headerLabel, Function pushTo, bool showNoPosts) {
    int displayedPostCount = 5;
    return FutureBuilder(
      future: exploreTimelineRef
          .orderBy('creationDate', descending: true)
          .getDocuments(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return showNoPosts ? circularProgress() : SizedBox();
          default:
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final updates = snapshot.data.documents;
              List<LatestPost> displayedUpdates = [];
              List<LatestPost> allPostType = [];
              for (var post in updates) {
                final String photoUrl = post.data['photoUrl'];
                final String title = post.data['title'];
                final int creationDate = post.data['creationDate'];
                final String type = post.data['type'];
                final String id = post.data['id'];
                final dynamic likes = post.data['likes'];
                final String uid = post.data['uid'];
                final String displayName = post.data['displayName'];
                final String profileImageUrl = post.data['profileImageUrl'];
                final String videoUrl = post.data['videoUrl'];

                final displayedPost = LatestPost(
                  photoUrl: photoUrl,
                  title: title,
                  creationDate: creationDate,
                  type: type,
                  uid: uid,
                  id: id,
                  displayName: displayName ?? '?',
                  likes: likes ?? {},
                  profileImageUrl: profileImageUrl,
                  videoUrl: videoUrl,
                );
                if (!blockedUids.contains(uid) && type == postType) {
                  allPostType.add(displayedPost);
                  if (displayedUpdates.length < displayedPostCount) {
                    displayedUpdates.add(displayedPost);
                  }
                }
              }
              if (displayedUpdates.isNotEmpty) {
                final double screenHeight = MediaQuery
                    .of(context)
                    .size
                    .height;
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 8.0, top: 20.0, bottom: 12.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(headerLabel,
                              style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
                          allPostType.length > displayedPostCount
                              ? GestureDetector(
                            child: Text('View All',
                                style: kAppBarTextStyle.copyWith(
                                    fontSize: 16.0, color: kColorRed)),
                            onTap: pushTo,
                          )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    postType == 'text'
                        ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayedUpdates)
                        : CarouselSlider.builder(
                      itemCount: displayedUpdates.length,
                      height: screenHeight / 3,
                      viewportFraction: 0.9,
                      enableInfiniteScroll:
                      allPostType.length > 1 ? true : false,
                      enlargeCenterPage: true,
                      itemBuilder: (context, i) {
                        var post = displayedUpdates[i];
                        return GestureDetector(
                          onTap: () =>
//                      final result = await Navigator.push(
//                        context,
//                        FadeRoute(
//                          page: FullScreenLatestPhoto(index: i, displayedUpdates: displayedUpdates),
//                        ),
//                      );
//                    },
                          Navigator.push(
                            context,
                            FadeRoute(
                              page: FullScreenLatestPhoto(
                                  index: i, displayedUpdates: displayedUpdates),
                            ),
                          ),
                          child: displayedUpdates[i],
                        );
                      },
                    ),
                  ],
                );
              } else {
                return showNoPosts
                    ? Center(
                  child: Text(
                    'No Posts Yet',
                    style: kDefaultTextStyle,
                  ),
                )
                    : SizedBox();
              }
            }
        }
      },
    );
  }

  buildNewLatestPosts() {
    int displayedPostCount = 10;
    return FutureBuilder(
      future: exploreTimelineRef
          .orderBy('creationDate', descending: true)
          .getDocuments(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return circularProgress();
          default:
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final updates = snapshot.data.documents;
              List<LatestPost> displayedLatest = [];
              List<LatestPost> displayedPhotos = [];
              List<LatestPost> allLatest = [];
              for (var post in updates) {
                final String photoUrl = post.data['photoUrl'];
                final String title = post.data['title'];
                final int creationDate = post.data['creationDate'];
                final String type = post.data['type'];
                final String id = post.data['id'];
                final dynamic likes = post.data['likes'];
                final String uid = post.data['uid'];
                final String displayName = post.data['displayName'];
                final String profileImageUrl = post.data['profileImageUrl'];
                final String videoUrl = post.data['videoUrl'];

                final displayedPost = LatestPost(
                  photoUrl: photoUrl,
                  title: title,
                  creationDate: creationDate,
                  type: type,
                  uid: uid,
                  id: id,
                  displayName: displayName ?? '?',
                  likes: likes ?? {},
                  profileImageUrl: profileImageUrl,
                  videoUrl: videoUrl,
                );

                if (!blockedUids.contains(uid)) {
                  allLatest.add(displayedPost);
                  if (displayedLatest.length < displayedPostCount) {
                    displayedLatest.add(displayedPost);
                    if (type == 'photo') {
                      displayedPhotos.add(displayedPost);
                    }
                  }
                }
              }
              if (displayedLatest.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ReusableHeaderLabel('Latest'),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                        shrinkWrap: true,
                        itemCount: displayedLatest.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () =>
                                Navigator.push(
                                  context,
                                  FadeRoute(
                                    page: FullScreenLatestPhoto(index: i - 1, displayedUpdates: displayedPhotos),
                                  ),
                                ),
                            child: displayedLatest[i],
                          );
                        },
                      ),
                      allLatest.length > displayedPostCount
                          ? Center(
                        child: ReusableRoundedCornerButton(
                          text: 'View All',
                          onPressed: () => print('go to view all'),
                          width: 40,
                          backgroundColor: Colors.transparent,
                          textColor: kColorLightGray,
                        ),
                      ) : SizedBox(),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'No Posts Yet',
                    style: kDefaultTextStyle,
                  ),
                );
              }
            }
        }
      },
    );
  }

  showContent() {
    if (isPageLoading) {
      return circularProgress();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildWeeklyTopViewed(),
          buildNewLatestPosts()
//                  buildLatestPosts('video', 'Videos', () => print('go to videos'), true),
//          buildLatestPosts(
//            'photo',
//            'Photos',
//                () => Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => ViewAllLatestPhotos(
//                  blockedUids: blockedUids,
//                  query: exploreTimelineRef
//                      .orderBy('creationDate', descending: true)
//                      .snapshots(),
//                ),
//              ),
//            ),
//            true,
//          ),
//          buildLatestPosts(
//              'text', 'Text',
//                  () => Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => ViewAllLatestText(
//                    blockedUids: blockedUids,
//                    query: exploreTimelineRef
//                        .orderBy('creationDate', descending: true)
//                        .snapshots(),
//                  ),
//                ),
//              ), false),
        ],
      );
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: kColorOffWhite,
      body: Theme(
          data: kTheme(context),
          child: isPageLoading ? circularProgress()
              : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              waterDropColor: kColorExtraLightGray,
              idleIcon: Icon(
                FontAwesomeIcons.search,
                color: kColorRed,
                size: 18.0,
              ),
              complete: Icon(
                FontAwesomeIcons.check,
                color: kColorGreen,
                size: 20.0,
              ),
              failed: Icon(
                FontAwesomeIcons.times,
                color: kColorRed,
                size: 20.0,
              ),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: showContent(),
              ),
            ),
          )),
    );
  }

  _onRefresh() {
    kSelectionClick();
    if (topWeeklyUsers.isNotEmpty) {
      fetchWeeklyUsers();
    } else {
      fetchAllTimeUsers();
    }
    _refreshController.refreshCompleted();
  }
}
