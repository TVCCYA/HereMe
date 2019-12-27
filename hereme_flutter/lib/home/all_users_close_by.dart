import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'home.dart';

class AllUsersCloseBy extends StatefulWidget {
  final double latitude;
  final double longitude;
  AllUsersCloseBy({this.latitude, this.longitude});

  @override
  _AllUsersCloseByState createState() => _AllUsersCloseByState(
        latitude: this.latitude,
        longitude: this.longitude,
      );
}

class _AllUsersCloseByState extends State<AllUsersCloseBy> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final double latitude;
  final double longitude;
  _AllUsersCloseByState({this.latitude, this.longitude});

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  streamCloseByUsers() {
    Geoflutterfire geo = Geoflutterfire();
    Query collectionRef = userLocationsRef;
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionRef).within(
              center: geo.point(latitude: latitude, longitude: longitude),
              radius: 0.4,
              field: 'position',
              strictMode: true,
            );

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        }
        List<User> usersAround = [];
        List<DocumentSnapshot> users = [];
        for (var data in snapshot.data) {
          users.add(data);
        }
        for (var user in users) {
          final imageUrl = user.data['profileImageUrl'];
          final uid = user.data['uid'];
          final hasAccountLinked = user.data['hasAccountLinked'];

          final displayedUser = User(
            profileImageUrl: imageUrl,
            uid: uid,
            hasAccountLinked: hasAccountLinked,
          );

          if (currentUser.uid != uid &&
              hasAccountLinked != null &&
              hasAccountLinked &&
              !currentUser.blockedUids.contains(uid) &&
              uid != adminUid) {
            usersAround.add(displayedUser);
          }
        }
        List<GridTile> gridTiles = [];
        usersAround.forEach((user) {
          gridTiles.add(
              GridTile(child: UserResult(user: user, locationLabel: 'Nearby')));
        });
        if (usersAround.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                child: Text('Everyone Within 1/4 Mile',
                    style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
              ),
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 1.0, right: 1.0),
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
                shrinkWrap: true,
                children: gridTiles,
              ),
            ],
          );
        } else {
          return Container(
            height: 150.0,
            child: Center(
              child: Text(
                'Nobody Nearby',
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: kColorOffWhite,
        elevation: 2.0,
        title: Text('Close By', style: kAppBarTextStyle),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            waterDropColor: Colors.grey[200],
            idleIcon: Icon(
              FontAwesomeIcons.user,
              color: kColorRed,
              size: 18.0,
            ),
            complete: Icon(
              FontAwesomeIcons. arrowDown,
              color: kColorLightGray,
              size: 20.0,
            ),
            failed: Icon(
              FontAwesomeIcons.times,
              color: kColorRed,
              size: 20.0,
            ),
          ),
          controller: _refreshController,
          onRefresh: () async {
            kShowSnackbar(
              key: _scaffoldKey,
              text: 'Your feed will auto update as someone comes within or leaves your vicinity',
              backgroundColor: kColorBlack71,
            );
            _refreshController.refreshCompleted();
          },
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50.0),
              child: streamCloseByUsers(),
            ),
          ),
        ),
      ),
    );
  }
}
