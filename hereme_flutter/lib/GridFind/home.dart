import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hereme_flutter/GridFind/all_users_close_by.dart';
import 'package:hereme_flutter/SettingsMenu/SocialMediasList.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/profile_page/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../registration/initial_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:flushbar/flushbar.dart';

final usersRef = Firestore.instance.collection('users');
final socialMediasRef = Firestore.instance.collection('socialMedias');
final knocksRef = Firestore.instance.collection('knocks');
final recentUploadsRef = Firestore.instance.collection('recentUploads');
final userLocationsRef = Firestore.instance.collection('userLocations');
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  final auth = FirebaseAuth.instance;
  bool _isAuth = false;
  bool _hasAccountLinked = false;

  List<User> closeByUsers = [];
  List<User> topTotalViewedUsers = [];

  double latitude;
  double longitude;
  bool _locationEnabled = false;
  bool _locationLoading = true;

  bool get wantKeepAlive => true;

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;
  Position position;

  @override
  void initState() {
    super.initState();
    getTopTotalViewedUsers();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    handleLoggedIn();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  getCurrentUser() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', currentUser.username);
    await prefs.setString('profileImageUrl', currentUser.profileImageUrl);
    await prefs.setString('uid', currentUser.uid);

    await getUserLocation(currentUser: currentUser);
    if (currentUser.hasAccountLinked) {
      setState(() {
        _hasAccountLinked = true;
      });
    } else {
      _hasAccountLinked = false;
    }
  }

  handleLoggedIn() async {
    if (await auth.currentUser() != null) {
      await getCurrentUser();
      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitialPage()));
    }
  }

  getUserLocation({User currentUser}) async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();

    if (geolocationStatus == GeolocationStatus.granted) {
      LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.high,
        distanceFilter: 175, //updates every 0.1 miles
      );
      positionStream = geolocator
          .getPositionStream(locationOptions)
          .listen((Position newPosition) async {
        setState(() {
          _locationLoading = false;
          _locationEnabled = true;
          latitude = newPosition.latitude;
          longitude = newPosition.longitude;
        });
        await setGeoFireData(
            currentUser: currentUser,
            latitude: newPosition.latitude,
            longitude: newPosition.longitude);
      });
    } else {
      setState(() {
        _locationLoading = false;
        _locationEnabled = false;
      });
    }
  }

  setGeoFireData({User currentUser, double latitude, double longitude}) async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint myLocation =
        geo.point(latitude: latitude, longitude: longitude);
    await userLocationsRef.document(currentUser.uid).setData({
      'position': myLocation.data,
      'profileImageUrl': currentUser.profileImageUrl,
      'uid': currentUser.uid,
    });
  }

  showStreamedCloseByUsers() {
    return _hasAccountLinked
        ? streamCloseByUsers()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                  child: Text('Close By',
                      style: kAppBarTextStyle.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.w400)),
                ),
                Container(
                  height: 100.0,
                  child: Center(
                    child: ReusableBottomActionSheetListTile(
                      iconData: FontAwesomeIcons.link,
                      title: 'Must Link an Account',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => MediasList()),
                        );
                      },
                    ),
                  ),
                ),
              ]);
  }

  streamCloseByUsers() {
    Geoflutterfire geo = Geoflutterfire();
    Query collectionRef = userLocationsRef.limit(5);
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
            gridTiles.add(GridTile(child: UserResult(user)));
          });
          if (usersAround.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                  child: Text('Close By',
                      style: kAppBarTextStyle.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.w400)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 1.0, right: 1.0),
                      crossAxisCount: 4,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      shrinkWrap: true,
                      children: gridTiles,
                    ),
                    FlatButton.icon(
                      icon: Icon(
                        FontAwesomeIcons.chevronCircleRight,
                        color: kColorBlack105,
                      ),
                      // use
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllUsersCloseBy(
                                    latitude: latitude,
                                    longitude: longitude,
                                  ))),
                      label: Text(
                        'Within 1/4 mile',
                        style: kDefaultTextStyle.copyWith(
                            fontWeight: FontWeight.w300, fontSize: 16.0),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.grey[200],
                    )
                  ],
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
        });
  }

  enabledLocation() {
    if (_locationLoading) {
      return circularProgress();
    } else if (_locationEnabled) {
      return showStreamedCloseByUsers();
    } else {
      return _showFlushBar();
    }
  }

  getTopTotalViewedUsers() async {
    QuerySnapshot snapshot = await usersRef
        .orderBy('totalVisitsCount', descending: true)
        .getDocuments();
    List<User> users =
        snapshot.documents.map((doc) => User.fromDocument(doc)).toList();
    setState(() {
      this.topTotalViewedUsers = users;
    });
  }

  buildTopViewed() {
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
          final username = user.data['username'];
          final imageUrl = user.data['profileImageUrl'];
          final uid = user.data['uid'];
          final weeklyVisitsCount = user.data['weeklyVisitsCount'];
          final totalVisitsCount = user.data['totalVisitsCount'];

          final displayedUser = User(
            username: username,
            profileImageUrl: imageUrl,
            uid: uid,
            weeklyVisitsCount: weeklyVisitsCount,
            totalVisitsCount: totalVisitsCount,
          );
          topUsers.add(displayedUser);
        }
        List<GridTile> gridTiles = [];
        topUsers.forEach((user) {
          gridTiles.add(GridTile(child: UserResult(user)));
        });
        if (topUsers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Most Viewed This Week',
                    style: kAppBarTextStyle.copyWith(
                        fontSize: 18.0, fontWeight: FontWeight.w400)),
              ),
              Container(
                height: 150,
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
          return buildTotalTopViewed();
        }
      },
    );
  }

  buildTotalTopViewed() {
    return FutureBuilder(
      future: usersRef.limit(10).getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<GridTile> gridTiles = [];
        topTotalViewedUsers.forEach((user) {
          gridTiles.add(GridTile(child: UserResult(user)));
        });
        if (topTotalViewedUsers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Top Viewed All Time',
                    style: kAppBarTextStyle.copyWith(
                        fontSize: 18.0, fontWeight: FontWeight.w400)),
              ),
              Container(
                height: 150,
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
            height: 150.0,
            child: Center(
              child: Text(
                'Nobody To Be Displayed',
                style: kAppBarTextStyle.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          );
        }
      },
    );
  }

  buildLiveChatsCloseBy() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
      child: Text('Live Chats By You',
          style: kAppBarTextStyle.copyWith(
              fontSize: 18.0, fontWeight: FontWeight.w400)),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: false,
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: kColorOffWhite,
        title: new Text(
          "HereMe",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: kColorPurple,
            fontFamily: 'Montserrat',
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              child: _isAuth
                  ? cachedNetworkImage(currentUser.profileImageUrl)
                  : Icon(FontAwesomeIcons.user, color: Colors.grey[200]),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(user: currentUser))),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Theme(
          data: kTheme(context),
          child: RefreshIndicator(
            onRefresh: () async =>
                await getUserLocation(currentUser: currentUser),
            child: Stack(
              children: <Widget>[
                Container(
                  height: screenHeight,
                  width: screenWidth,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 50.0),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 4.0),
                        buildTopViewed(),
                        Divider(color: Colors.grey[300]),
                        enabledLocation(),
                        Divider(color: Colors.grey[300]),
                        buildLiveChatsCloseBy(),
                        Divider(color: Colors.grey[300]),
//                        Container(height: 300, color: Colors.red),
//                        Container(height: 300, color: Colors.pinkAccent),
//                        Container(height: 300, color: Colors.purpleAccent),
                      ],
                    ),
                  ),

                  /* If you don't do the bottom scroll notification...
                         REMOVE padding from SingleChildScrollView and
                         REPLACE the Stack wrapping with just the
                         SingleChildScrollView Widget
                       */
                ),
                Align(
                  child: Container(
                    height: 50.0,
                    width: screenWidth,
                    color: Colors.yellow,
                    child: Center(
                        child: Text('BOTTOM SCROLLY NOTIFICATION GOES HERE')),
                  ),
                  alignment: Alignment.bottomCenter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showFlushBar() {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.white,
      isDismissible: false,
      duration: Duration(seconds: 4),
      icon: Icon(
        FontAwesomeIcons.searchLocation,
        color: kColorRed,
      ),
      mainButton: FlatButton(
        onPressed: () => PermissionHandler().openAppSettings(),
        child: Text(
          "Open",
          style: kAppBarTextStyle.copyWith(color: kColorBlue),
        ),
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        "Location Disabled",
        style: kAppBarTextStyle,
      ),
      messageText: Text(
        "In order to show what's happening around you we need access to your location. Please tap Open to enable your location in Settings",
        style: kDefaultTextStyle,
      ),
    );
  }
}
