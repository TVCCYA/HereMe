import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:loadmore/loadmore.dart';
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
  List<LatestPost> latestPhotoPosts = [];
  bool isPageLoading = true;
  bool isLatestLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeeklyUsers();
  }

  fetchWeeklyUsers() async {
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
      getTimeline(topWeeklyUsers);
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
    });
    getTimeline(topAllTimeUsers);
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

  getTimeline(List<User> users) async {
    List<LatestPost> posts = [];
    List<LatestPost> photoPosts = [];
    for (var user in users) {
      QuerySnapshot snapshot =
          await updateRef.document(user.uid).collection('posts').limit(10).getDocuments();
      if (snapshot.documents.length > 0) {
        for (var doc in snapshot.documents) {
//          LatestPost post = LatestPost.fromDocument(doc);

          final String postId = doc.data['id'];
          final String uid = doc.data['uid'];
          final String title = doc.data['title'];
          final String photoUrl = doc.data['photoUrl'];
          final int creationDate = doc.data['creationDate'];
          final String type = doc.data['type'];
          final dynamic likes = doc.data['likes'];

          LatestPost post = LatestPost(
            id: postId,
            uid: uid,
            title: title,
            displayName: user.displayName ?? user.username,
            photoUrl: photoUrl,
            creationDate: creationDate,
            type: type,
            profileImageUrl: user.profileImageUrl,
            likes: likes ?? {},
            isHome: true,
          );

          posts.add(post);
          if (type == 'photo') {
            photoPosts.add(post);
            photoPosts.sort((p1, p2) {
              return p2.creationDate.compareTo(p1.creationDate);
            });
          }
          posts.sort((p1, p2) {
            return p2.creationDate.compareTo(p1.creationDate);
          });
        }
      }
    }
    if (this.mounted)
      setState(() {
        latestPosts = posts;
        latestPhotoPosts = photoPosts;
        isLatestLoading = false;
      });
  }

  buildLatestPosts() {
    return isLatestLoading
        ? circularProgress()
        : latestPosts.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ReusableHeaderLabel('Latest'),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                    shrinkWrap: true,
                    itemCount: latestPosts.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          FadeRoute(
                            page: FullScreenLatestPhoto(
                                index: latestPhotoPosts.indexOf(latestPosts[i]),
                                displayedUpdates: latestPhotoPosts),
                          ),
                        ),
                        child: latestPosts[i],
                      );
                    },
                  ),
                ],
              )
            : Center(
                child: Text(
                  'No Posts Yet',
                  style: kDefaultTextStyle,
                ),
              );
  }

  showContent() {
    return isPageLoading ? circularProgress() : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildWeeklyTopViewed(),
        buildLatestPosts(),
      ],
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: kColorOffWhite,
      body: Theme(
        data: kTheme(context),
        child: SmartRefresher(
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
        ),
      ),
    );
  }

  _onRefresh() {
    setState(() {
      isLatestLoading = true;
      latestPosts = [];
    });
    kSelectionClick();
    if (topWeeklyUsers.isNotEmpty) {
      fetchWeeklyUsers();
    } else {
      fetchAllTimeUsers();
    }
    _refreshController.refreshCompleted();
  }
}
