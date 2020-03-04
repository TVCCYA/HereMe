import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/models/user.dart';
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

class _ExploreState extends State<Explore> {
  final List<String> blockedUids;

  _ExploreState({this.blockedUids});

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
        if (topUsers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                child: Text('Most Viewed This Week',
                    style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
              ),
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
//              Center(
//                child: CircleList(
//                  origin: Offset(0, 0),
//                  children: gridTiles,
//                ),
//              ),
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

          final displayedUser = User(
              profileImageUrl: imageUrl,
              uid: uid,
              city: city,
              hasAccountLinked: hasAccountLinked);
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
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                child: Text('Top Viewed All Time',
                    style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
              ),
              Container(
                height: 150.0,
                child: GridView.count(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  crossAxisCount: 1,
                  childAspectRatio: 1.33,
                  mainAxisSpacing: 2.5,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      body: SafeArea(
        child: Theme(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildWeeklyTopViewed(),
              ],
            ),
          )
        ),
      ),
    );
  }

  _onRefresh() {
    kSelectionClick();
    print('refresh');
    _refreshController.refreshCompleted();
  }
}
