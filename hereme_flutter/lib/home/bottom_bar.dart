import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/explore.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/registration/photo_add.dart';
import 'package:hereme_flutter/user_profile/new_profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

final usersRef = Firestore.instance.collection('users');
final socialMediasRef = Firestore.instance.collection('socialMedias');
final knocksRef = Firestore.instance.collection('knocks');
final recentUploadsRef = Firestore.instance.collection('recentUploads');
final liveChatsRef = Firestore.instance.collection('liveChats');
final userLocationsRef = Firestore.instance.collection('userLocations');
final liveChatLocationsRef = Firestore.instance.collection('liveChatLocations');
final liveChatMessagesRef = Firestore.instance.collection('liveChatMessages');
final activityRef = Firestore.instance.collection('activity');
final usersInChatRef = Firestore.instance.collection('usersInChat');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final latestRef = Firestore.instance.collection('latest');
final usersNearbyRef = Firestore.instance.collection('usersNearby');
final topUsersRef = Firestore.instance.collection('topUsers');
final timelineRef = Firestore.instance.collection('timeline');
final exploreTimelineRef = Firestore.instance.collection('exploreTimeline');
final reportedUsersRef = Firestore.instance.collection('reportedUsers');

User currentUser;
double currentLatitude;
double currentLongitude;
final bool isAdmin = currentUser.uid == 'z3Gq1WeepHfoT5HGVIWJo7oDxiX2';
final String adminUid = 'z3Gq1WeepHfoT5HGVIWJo7oDxiX2';
final auth = FirebaseAuth.instance;

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _isAuth = false;
  bool pageLoading = true;
  List<String> blockedUids = [];
  TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    handleLoggedIn();
    _tabController = new TabController(vsync: this, length: 2);
  }

  handleLoggedIn() async {
    if (await auth.currentUser() != null) {
      await getCurrentUser();
      if (this.mounted)
        setState(() {
          _isAuth = true;
          pageLoading = false;
        });
      await configurePushNotifications();
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => InitialPage()),
          (Route<dynamic> route) => false);
      if (this.mounted)
        setState(() {
          _isAuth = false;
          pageLoading = false;
        });
    }
  }

  configurePushNotifications() async {
    final user = await auth.currentUser();
    if (Platform.isIOS) getIOSPermission();
    _firebaseMessaging.getToken().then((token) {
      usersRef.document(user.uid).updateData({
        'androidNotificationToken': token,
      });
    });

    _firebaseMessaging.configure(
//      onLaunch: (Map<String, dynamic> message) async {},
//      onResume: (Map<String, dynamic> message) async {},
//      onMessage: (Map<String, dynamic> message) async {
//        print('on message: $message\n');
//        final String recipientId = message['data']['recipient'];
//        final String body = message['notification']['body'];
//        if (recipientId == user.uid) {
//          kShowSnackbar(
//            key: _scaffoldKey,
//            text: body,
//            backgroundColor: kColorBlack71,
//          );
//        }
//        print('NOTIFICATION NOT SHOWN');
//      },
        );
  }

  getIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {});
  }

  getCurrentUser() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);
    if (blockedUids != null) {
      currentUser.blockedUids = blockedUids;
    }
    fetchBlockedUsers();

    if (currentUser.profileImageUrl == null) {
      Navigator.of(context).pushAndRemoveUntil(createRoute(PhotoAdd()),
              (Route<dynamic> route) => false);
    }

    if (currentUser.displayName == null) {
      Navigator.of(context).pushAndRemoveUntil(createRoute(CreateDisplayName(showBackButton: false)),
              (Route<dynamic> route) => false);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', currentUser.username);
    await prefs.setString('profileImageUrl', currentUser.profileImageUrl);
    await prefs.setString('uid', currentUser.uid);
    await prefs.setString('backgroundImageUrl', currentUser.backgroundImageUrl);
  }

  fetchBlockedUsers() {
    List<String> uids = [];
    if (currentUser.blockedUserUids != null) {
      currentUser.blockedUserUids.forEach((uid, val) {
        uids.add(uid);
        if (this.mounted)
          setState(() {
            uids.forEach((i) {
              if (!blockedUids.contains(i)) {
                this.blockedUids.add(i);
              }
            });
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 4,
        brightness: Brightness.light,
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: kColorOffWhite,
        title: Theme(
          data: kTheme(context),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
            indicatorPadding: EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
            indicatorWeight: 1.5,
            indicatorColor: kColorRed,
            labelColor: kColorRed,
            unselectedLabelColor: kColorLightGray,
            labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
            tabs: [
              Tab(text: 'Nearby'),
              Tab(text: 'Explore'),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: _isAuth ? GestureDetector(
              child: cachedUserResultImage(currentUser.profileImageUrl, 35, false),
              onTap: () =>
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewProfile(
                          user: currentUser,
                          locationLabel: currentUser.city ?? 'Here'),
                  ),
              ),
            ) : SizedBox(),
          ),
        ],
      ),
      body: pageLoading ? circularProgress() : TabBarView(
        controller: _tabController,
        children: <Widget>[
          Home(blockedUids: blockedUids),
          Explore(blockedUids: blockedUids),
        ],
      ),
    );
  }
}
