import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/notifications/notification_page.dart';

class AllFollows extends StatefulWidget {
  @override
  _AllFollowsState createState() => _AllFollowsState();
}

class _AllFollowsState extends State<AllFollows>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: kColorBlack62, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 4,
          brightness: Brightness.light,
          centerTitle: true,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Theme(
            data: kTheme(context),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
              indicatorPadding:
                  EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
              indicatorWeight: 1.5,
              indicatorColor: kColorRed,
              labelColor: kColorRed,
              unselectedLabelColor: kColorLightGray,
              labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
              tabs: [
                Tab(text: 'Liked By'),
                Tab(text: 'Likes'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Followers(),
            LikedProfiles(),
          ],
        ),
      ),
    );
  }
}

class Followers extends StatelessWidget {

  fetchFollowers() {
    return FutureBuilder(
        future: followersRef
            .document(currentUser.uid)
            .collection('users')
            .getDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<DocumentSnapshot> followers = snapshot.data.documents;
          List<FollowerTile> displayedFollowers = [];
          for (var user in followers) {
            final String uid = user.documentID;
            final int creationDate = user.data['creationDate'];

            final follower = FollowerTile(
              uid: uid,
              creationDate: creationDate ?? 0,
              showDate: false,
              isUserLikes: false,
            );

            displayedFollowers.add(follower);
            displayedFollowers.sort((p1, p2) {
              return p2.creationDate.compareTo(p1.creationDate);
            });
          }
          if (displayedFollowers.isNotEmpty) {
            return Column(
              children: displayedFollowers,
            );
          } else {
            return SizedBox();
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight,
      width: screenWidth,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: fetchFollowers(),
      ),
    );
  }
}

class LikedProfiles extends StatelessWidget {

  fetchFollowing() {
    return FutureBuilder(
      future: followingRef
          .document(currentUser.uid)
          .collection('users')
          .getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final List<DocumentSnapshot> followers = snapshot.data.documents;
        List<FollowerTile> displayedFollowers = [];
        for (var user in followers) {
          final String uid = user.documentID;
          final int creationDate = user.data['creationDate'];

          final follower = FollowerTile(
            uid: uid,
            creationDate: creationDate ?? 0,
            showDate: false,
            isUserLikes: true,
          );

          displayedFollowers.add(follower);
          displayedFollowers.sort((p1, p2) {
            return p2.creationDate.compareTo(p1.creationDate);
          });
        }
        if (displayedFollowers.isNotEmpty) {
          return Column(
            children: displayedFollowers,
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight,
      width: screenWidth,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: fetchFollowing(),
      ),
    );
  }
}

