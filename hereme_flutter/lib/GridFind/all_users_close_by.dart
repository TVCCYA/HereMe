import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/widgets/user_result.dart';

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
  final double latitude;
  final double longitude;
  _AllUsersCloseByState({this.latitude, this.longitude});

  @override
  void initState() {
    super.initState();
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

          final displayedUser = User(
            profileImageUrl: imageUrl,
            uid: uid,
          );
          if (currentUser.uid != uid) {
            usersAround.add(displayedUser);
          }
        }
        List<GridTile> gridTiles = [];
        usersAround.forEach((user) {
          gridTiles.add(GridTile(child: UserResult(user: user, locationLabel: 'Nearby')));
        });
        if (usersAround.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                child: Text('Everyone Within 1/4 Mile',
                    style: kAppBarTextStyle.copyWith(
                        fontSize: 18.0, fontWeight: FontWeight.w400)),
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
                style: kAppBarTextStyle.copyWith(fontWeight: FontWeight.w400),
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
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        backgroundColor: kColorOffWhite,
        elevation: 2.0,
        title: Text('Close By', style: kAppBarTextStyle),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack105,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            Flushbar(
              messageText: Text(
                'Your feed will auto update as someone comes within or leaves your vicinity',
                style: kDefaultTextStyle.copyWith(color: Colors.white, fontSize: 14.0),
              ),
              backgroundColor: kColorBlack105,
              duration: Duration(seconds: 5),
            )..show(context);
          },
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50.0),
              physics: AlwaysScrollableScrollPhysics(),
              child: streamCloseByUsers(),
            ),
          ),
        ),
      ),
    );
  }
}
