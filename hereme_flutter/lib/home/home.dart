import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_ad_manager/banner.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hereme_flutter/home/all_live_chats_close_by.dart';
import 'package:hereme_flutter/home/all_users_close_by.dart';
import 'package:hereme_flutter/home/view_all_latest_photos.dart';
import 'package:hereme_flutter/home/view_all_latest_text.dart';
import 'package:hereme_flutter/live_chat/add_live_chat.dart';
import 'package:hereme_flutter/live_chat/live_chat_result.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/settings/choose_account.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:flushbar/flushbar.dart';
import 'bottom_bar.dart';

class Home extends StatefulWidget {
  final List<String> blockedUids;

  Home({this.blockedUids});

  @override
  _HomeState createState() => _HomeState(
        blockedUids: this.blockedUids,
      );
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  final List<String> blockedUids;

  _HomeState({this.blockedUids});

  bool get wantKeepAlive => true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool hideMe = false;
  bool isPageLoading = true;
  bool isLatestLoading = true;
  bool _hasAccountLinked = currentUser.hasAccountLinked;

  double latitude;
  double longitude;
  bool _locationEnabled = false;
  bool isLocationLoading = true;

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;
  Position position;

  List<User> usersNearby = [];
  List<LatestPost> latestPosts = [];
  List<LatestPost> latestPhotoPosts = [];

  @override
  void initState() {
    super.initState();
    getStreamedLocation();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    isHideMe();
    if (hideMe) {
      _locationEnabled = false;
    }
    await checkHasAccountLinked();
  }

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) {
      positionStream.cancel();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkHasAccountLinked() async {
    if (currentUser.hasAccountLinked) {
      if (this.mounted)
        setState(() {
          _hasAccountLinked = true;
        });
    } else {
      if (this.mounted)
        setState(() {
          _hasAccountLinked = false;
        });
    }
  }

  getNearbyUsers() async {
    Geoflutterfire geo = Geoflutterfire();
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: userLocationsRef).within(
              center: geo.point(latitude: latitude, longitude: longitude),
              radius: 0.4,
              field: 'position',
              strictMode: true,
            );

    List<User> users = [];
    stream.listen((documents) {
      users = documents.map((doc) => User.fromDocument(doc)).toList();
      if (users.isNotEmpty) {
        if (this.mounted)
          setState(() {
            this.usersNearby = users;
          });
        getTimeline();
      }
      if (this.mounted)
        setState(() {
          isPageLoading = false;
        });
    });
  }
  
  getTimeline() async {
    List<LatestPost> posts = [];
    List<LatestPost> photoPosts = [];
    for (var user in usersNearby) {
      QuerySnapshot snapshot =
      await updateRef.document(user.uid).collection('posts').limit(10).getDocuments();
      if (snapshot.documents.length > 0) {
        for (var doc in snapshot.documents) {
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

  isHideMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted)
      setState(() {
        hideMe = prefs.getBool('hideMe') ?? false;
      });
  }

  getCurrentLocation() async {
    if (this.mounted)
      setState(() {
        isLocationLoading = true;
        _locationEnabled = false;
      });
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();

    if (geolocationStatus != GeolocationStatus.granted || hideMe) {
      if (this.mounted)
        setState(() {
          isLocationLoading = false;
          _locationEnabled = false;
        });
    } else {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (this.mounted)
        setState(() {
          isLocationLoading = false;
          _locationEnabled = true;
          latitude = position.latitude;
          longitude = position.longitude;
        });
      await setGeoFireData();
      await setUserCityInFirestore();
    }
  }

  getStreamedLocation() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    geolocationStatus = GeolocationStatus.granted;

    if (geolocationStatus != GeolocationStatus.granted) {
      if (this.mounted)
        setState(() {
          isLocationLoading = false;
          _locationEnabled = false;
        });
    } else {
      LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.high,
        distanceFilter: 175, //updates every 0.1 miles
      );
      positionStream = geolocator
          .getPositionStream(locationOptions)
          .listen((Position newPosition) async {
        if (this.mounted)
          setState(() {
            isLocationLoading = false;
            _locationEnabled = true;
            latitude = newPosition.latitude;
            longitude = newPosition.longitude;
            currentLatitude = newPosition.latitude;
            currentLongitude = newPosition.longitude;
          });
        await setGeoFireData();
        await setUserCityInFirestore();
        if (currentUser.hasAccountLinked) {
          await getNearbyUsers();
        }
      });
    }
  }

  setUserCityInFirestore() async {
    List<Placemark> placemark =
        await geolocator.placemarkFromCoordinates(latitude, longitude);
    placemark.forEach((mark) {
      usersRef.document(currentUser.uid).updateData({
        'city': mark.locality,
      });
    });
  }

  setGeoFireData() async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint myLocation =
        geo.point(latitude: latitude, longitude: longitude);
    await userLocationsRef.document(currentUser.uid).setData({
      'position': myLocation.data,
      'profileImageUrl': currentUser.profileImageUrl,
      'uid': currentUser.uid,
      'hasAccountLinked': _hasAccountLinked,
      'hideMe': hideMe,
      'username': currentUser.username,
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
                child: Text('See People Nearby',
                    style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
              ),
              Container(
                height: 75.0,
                child: Center(
                  child: ReusableBottomActionSheetListTile(
                    iconData: FontAwesomeIcons.link,
                    title: 'Must Link an Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ChooseAccount()),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }

  streamCloseByUsers() {
    int displayedUserCount = 10;
    Geoflutterfire geo = Geoflutterfire();
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: userLocationsRef).within(
              center: geo.point(latitude: latitude, longitude: longitude),
              radius: 0.4,
              field: 'position',
              strictMode: true,
            );

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        List<User> usersAround = [];
        List<DocumentSnapshot> users = [];
        for (var data in snapshot.data) {
          users.add(data);
        }
        for (var user in users) {
          final String imageUrl = user.data['profileImageUrl'];
          final String uid = user.data['uid'];
          final bool hasAccountLinked = user.data['hasAccountLinked'];
          final bool hideMe = user.data['hideMe'];
          final String username = user.data['username'];

          final displayedUser = User(
            profileImageUrl: imageUrl,
            uid: uid,
            hasAccountLinked: hasAccountLinked,
            username: username ?? 'name',
          );

          if (currentUser.uid != uid &&
              !hideMe &&
              hasAccountLinked != null &&
              hasAccountLinked &&
              !blockedUids.contains(uid) &&
              uid != adminUid &&
              usersAround.length < displayedUserCount) {
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
                padding: EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ReusableHeaderLabel('Around You', top: 12.0),
                    users.length > displayedUserCount
                        ? GestureDetector(
                            child: Text('View All',
                                style: kAppBarTextStyle.copyWith(
                                    fontSize: 16.0, color: kColorRed)),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllUsersCloseBy(
                                          latitude: latitude,
                                          longitude: longitude,
                                          blockedUids: blockedUids,
                                        ))),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
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
              ),
            ],
          );
        } else {
          return Container(
            height: 75.0,
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

  enabledLocationFetchUsers() {
    if (hideMe) {
      return _disableHideMe();
    } else if (isLocationLoading) {
      getCurrentLocation();
      return circularProgress();
    }
    if (_locationEnabled) {
      return showStreamedCloseByUsers();
    } else if (!_locationEnabled) {
      return _showNoLocationFlushBar();
    } else {
      return SizedBox();
    }
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
    if (isLocationLoading) {
      return circularProgress();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          enabledLocationFetchUsers(),
          buildLatestPosts(),
        ],
      );
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      body: Theme(
        data: kTheme(context),
        child: SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  waterDropColor: kColorExtraLightGray,
                  idleIcon: Icon(
                    FontAwesomeIcons.mapMarkerAlt,
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

  _onRefresh() async {
    setState(() {
      isLatestLoading = true;
      latestPosts = [];
    });
    kSelectionClick();
    await getCurrentLocation();
    await getNearbyUsers();
    _refreshController.refreshCompleted();
  }

  _disableHideMe() {
    return Container(
      height: 50.0,
      color: kColorBlue.withOpacity(0.75),
      child: FlatButton(
        splashColor: kColorExtraLightGray,
        highlightColor: Colors.transparent,
        onPressed: () {
          kHandleHideMe(_scaffoldKey);
          if (this.mounted)
            setState(() {
              hideMe = false;
              isLocationLoading = true;
            });
          getCurrentLocation();
        },
        child: Center(
          child: Text(
            'Disable Hide Me',
            style: kAppBarTextStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _showNoLocationFlushBar() {
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
        splashColor: kColorExtraLightGray,
        highlightColor: Colors.transparent,
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
        "In order to show what's happening around you we need access to your location. Tap Open to enable your location in Settings",
        style: kDefaultTextStyle,
      ),
    );
  }
}
