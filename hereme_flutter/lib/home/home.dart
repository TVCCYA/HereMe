import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:circle_list/circle_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:hereme_flutter/live_chat/add_live_chat.dart';
import 'package:hereme_flutter/live_chat/live_chat_result.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/registration/photo_add.dart';
import 'package:hereme_flutter/settings/choose_account.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../registration/initial_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:flushbar/flushbar.dart';
import 'bottom_bar.dart';

class Home extends StatefulWidget {
  final List<String> blockedUids;
  final bool hasAccountLinked;

  Home({this.blockedUids, this.hasAccountLinked});

  @override
  _HomeState createState() => _HomeState(
        blockedUids: this.blockedUids,
        hasAccountLinked: this.hasAccountLinked,
      );
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  final List<String> blockedUids;
  final bool hasAccountLinked;

  _HomeState({this.blockedUids, this.hasAccountLinked});

  bool get wantKeepAlive => true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool hideMe = false;
  bool pageLoading = true;

  double latitude;
  double longitude;
  bool _locationEnabled = false;
  bool _locationLoading = true;

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;
  Position position;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    isHideMe();
    if (hideMe) {
      _locationEnabled = false;
    } else {
      await getCurrentLocation();
    }
    print(userUIDs.length);
  }

  @override
  void dispose() {
    if (positionStream != null) {
      positionStream.cancel();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  isHideMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted)
      setState(() {
        hideMe = prefs.getBool('hideMe') ?? false;
      });
  }

  getCurrentLocation() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();

    if (geolocationStatus != GeolocationStatus.granted || hideMe) {
      if (this.mounted)
        setState(() {
          _locationLoading = false;
          _locationEnabled = false;
        });
    } else {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (this.mounted)
        setState(() {
          _locationLoading = false;
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
          _locationLoading = false;
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
            _locationLoading = false;
            _locationEnabled = true;
            latitude = newPosition.latitude;
            longitude = newPosition.longitude;
            currentLatitude = newPosition.latitude;
            currentLongitude = newPosition.longitude;
          });
        await setGeoFireData();
        await setUserCityInFirestore();
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
      'hasAccountLinked': hasAccountLinked,
      'hideMe': hideMe,
    });
  }

  showStreamedCloseByUsers() {
    return hasAccountLinked
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

  List<String> userUIDs = [];

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
            final imageUrl = user.data['profileImageUrl'];
            final uid = user.data['uid'];
            final bool hasAccountLinked = user.data['hasAccountLinked'];
            final bool hideMe = user.data['hideMe'];

            final displayedUser = User(
              profileImageUrl: imageUrl,
              uid: uid,
              hasAccountLinked: hasAccountLinked,
            );

            if (currentUser.uid != uid &&
                !hideMe &&
                hasAccountLinked != null &&
                hasAccountLinked &&
                usersAround.length < displayedUserCount &&
                !blockedUids.contains(uid) &&
                uid != adminUid) {
              usersAround.add(displayedUser);
            }
          }

          List<GridTile> gridTiles = [];
          usersAround.forEach((user) {
            if (!userUIDs.contains(user.uid)) {
              userUIDs.add(user.uid);
            }
            gridTiles.add(GridTile(
                child: UserResult(user: user, locationLabel: 'Nearby')));
          });
          if (usersAround.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                  child: Text('Around You',
                      style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 120,
                      child: GridView.count(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        crossAxisCount: 1,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 1.0,
                        scrollDirection: Axis.horizontal,
                        children: gridTiles,
                      ),
                    ),
                    users.length > displayedUserCount
                        ? GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, right: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text('See All',
                                      style: kAppBarTextStyle.copyWith(
                                          fontSize: 16)),
                                  SizedBox(width: 4.0),
                                  Icon(FontAwesomeIcons.chevronRight, size: 14),
                                ],
                              ),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllUsersCloseBy(
                                          latitude: latitude,
                                          longitude: longitude,
                                        ))),
                          )
                        : SizedBox(),
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

  fetchNearbyLatest() {
    if (userUIDs.isNotEmpty) {
      return StreamBuilder(
        stream: updateRef
            .document(userUIDs.last)
            .collection('posts')
            .orderBy('creationDate', descending: true)
            .where('type', isEqualTo: 'photo')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final updates = snapshot.data.documents;
          List<UpdatePost> displayedUpdates = [];
          for (var post in updates) {

            final String photoUrl = post.data['photoUrl'];
            final String title = post.data['title'];
            final int creationDate = post.data['creationDate'];
            final String type = post.data['type'];
            final String id = post.data['id'];
            final String uid = post.data['uid'];
            final dynamic likes = post.data['likes'];

            final displayedPost = UpdatePost(
              photoUrl: photoUrl,
              title: title,
              creationDate: creationDate,
              type: type,
              uid: uid,
              id: id,
              displayName: 'name',
              likes: likes ?? {},
              width: 105,
            );
            displayedUpdates
                .add(displayedPost);
          }
          if (displayedUpdates.isNotEmpty) {
            return Column(children: displayedUpdates);
          } else {
            return Center(
              child: Text(
                'No Posts Yet',
                style: kDefaultTextStyle,
              ),
            );
          }
        },
      );
    } else {
      return Container(
        height: 50,
        width: 200,
        color: kColorDarkBlue,
      );
    }
  }

  enabledLocationFetchUsers() {
    if (hideMe) {
      return _disableHideMe();
    } else if (_locationLoading) {
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

  enabledLocationFetchChats() {
    if (hideMe) {
      return SizedBox();
    } else if (_locationLoading) {
      getCurrentLocation();
      return circularProgress();
    }
    if (_locationEnabled) {
      return showStreamedCloseByChats();
    } else {
      return SizedBox();
    }
  }

  showStreamedCloseByChats() {
    return hasAccountLinked ? streamCloseByChats() : SizedBox();
  }

  streamCloseByChats() {
    Geoflutterfire geo = Geoflutterfire();
    Query collectionRef = liveChatLocationsRef;
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
          List<LiveChatResult> chatsAround = [];
          List<DocumentSnapshot> chats = [];
          for (var data in snapshot.data) {
            chats.add(data);
          }
          for (var chat in chats) {
            final title = chat.data['title'];
            final creationDate = chat.data['creationDate'];
            final chatId = chat.data['chatId'];
            final hostDisplayName = chat.data['hostDisplayName'] ?? '';
            final hostUid = chat.data['uid'];
            final hostRed = chat.data['hostRed'] ?? 91;
            final hostGreen = chat.data['hostGreen'] ?? 71;
            final hostBlue = chat.data['hostBlue'] ?? 188;
            final endDate = chat.data['endDate'];

            GeoPoint point = chat.data['position']['geopoint'];
            double distance = geo
                .point(latitude: point.latitude, longitude: point.longitude)
                .distance(lat: latitude, lng: longitude);
            double distanceFromChat = distance / 1.609;

            int timeLeft = endDate - DateTime.now().millisecondsSinceEpoch;
            bool hasChatEnded = timeLeft <= 0;

            if (hasChatEnded) {
              kHandleRemoveAllLiveChatData(chatId, hostUid);
            }

            final displayedChat = LiveChatResult(
              title: title,
              creationDate: creationDate,
              chatId: chatId,
              chatHostUid: hostUid,
              chatHostDisplayName: hostDisplayName,
              hostRed: hostRed,
              hostGreen: hostGreen,
              hostBlue: hostBlue,
              duration: kTimeRemaining(timeLeft),
              distanceFromChat: distanceFromChat,
            );
            if (!blockedUids.contains(hostUid) && chatsAround.length < 3) {
              chatsAround.add(displayedChat);
            }
          }
          if (chatsAround.isNotEmpty) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                    child: Text('Live Chats Nearby',
                        style: kAppBarTextStyle.copyWith(fontSize: 16.0)),
                  ),
                  Column(children: chatsAround),
                  chats.length > 3
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.chevronCircleRight,
                              color: kColorBlack71,
                              size: 20.0,
                            ),
                            // use
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllLiveChatsCloseBy(
                                          latitude: latitude,
                                          longitude: longitude,
                                        ))),
                            label: Text(
                              'Within 1 mile',
                              style: kDefaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w300, fontSize: 16.0),
                            ),
                            splashColor: Colors.transparent,
                            highlightColor: kColorExtraLightGray,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
                  child: Text('No Live Chats',
                      style: kAppBarTextStyle.copyWith(
                          fontSize: 16.0, color: kColorRed)),
                ),
                Container(
                  height: 75.0,
                  child: Center(
                    child: ReusableBottomActionSheetListTile(
                      iconData: FontAwesomeIcons.comments,
                      title: 'Create Live Chat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  currentUser.displayName != null
                                      ? AddLiveChat()
                                      : CreateDisplayName()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      body: SafeArea(
        child: Theme(
          data: kTheme(context),
          child: _locationLoading
              ? circularProgress()
              : SmartRefresher(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      enabledLocationFetchUsers(),
                      fetchNearbyLatest()
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _onRefresh() {
    kSelectionClick();
    getCurrentLocation();
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
              _locationLoading = true;
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
