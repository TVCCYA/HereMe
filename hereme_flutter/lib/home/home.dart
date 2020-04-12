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
  bool pageLoading = true;
  bool _hasAccountLinked = currentUser.hasAccountLinked;

  double latitude;
  double longitude;
  bool _locationEnabled = false;
  bool _locationLoading = true;

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;
  Position position;

  List<User> usersNearby = [];
  bool isPostsLoading = true;

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
      removeNearbyUsersFromFirestore();
    }
  }

  getNearbyUsers() async {
    int count = 0;
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
        for (var user in users) {
          usersNearbyRef
              .document(currentUser.uid)
              .collection('users')
              .document(user.uid)
              .setData({}).whenComplete(() {
            print('adding nearby ${count++}');
          });
        }
        if (this.mounted)
          setState(() {
            this.usersNearby = users;
          });
      }
      if (this.mounted)
        setState(() {
          isPostsLoading = false;
        });
    });
    await getNearbyUsersFromFirestore();
  }

  removeNearbyUsersFromFirestore() {
    usersNearbyRef
        .document(currentUser.uid)
        .collection('users')
        .getDocuments()
        .then((snapshot) {
      for (var doc in snapshot.documents) {
        if (doc.exists) {
          doc.reference.delete();
        }
      }
    });
  }

  getNearbyUsersFromFirestore() async {
    List<String> uids = [];
    List<String> uidOnFeed = [];
    final ref = usersNearbyRef.document(currentUser.uid).collection('users');
    ref.getDocuments().then((snapshot) {
      for (var doc in snapshot.documents) {
        if (doc.exists) {
          uids.add(doc.documentID);
        }
      }
      for (var uid in uids) {
        for (var user in usersNearby) {
          if (uid == user.uid) {
            uidOnFeed.add(uid);
          }
        }
        if (!uidOnFeed.contains(uid)) {
          ref.document(uid).delete();
        }
      }
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
        _locationLoading = true;
        _locationEnabled = false;
      });
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
                    ReusableSectionLabel('Around You', top: 12.0),
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

  buildNewLatestPosts() {
    int displayedPostCount = 10;
    return FutureBuilder(
      future: timelineRef
          .document(currentUser.uid)
          .collection('timelinePosts')
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
                      ReusableSectionLabel('Latest'),
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
                        child: Container(
                          height: 30,
                          child: TopProfileHeaderButton(
                            text: 'View All',
                            onPressed: () => print('go to view all'),
                            width: 40,
                            backgroundColor: Colors.transparent,
                            textColor: kColorLightGray,
                            splashColor: kColorExtraLightGray,
                          ),
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

  buildNearbyLatestPosts(
      String postType, String headerLabel, Function pushTo, bool showNoPosts) {
    int displayedPostCount = 5;
    return FutureBuilder(
      future: timelineRef
          .document(currentUser.uid)
          .collection('timelinePosts')
          .orderBy('creationDate', descending: true)
          .getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return showNoPosts ? circularProgress() : SizedBox();
        }
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
          );
          if (!blockedUids.contains(uid) && type == postType) {
            allPostType.add(displayedPost);
            if (displayedUpdates.length < displayedPostCount) {
              displayedUpdates.add(displayedPost);
            }
          }
        }
        if (displayedUpdates.isNotEmpty) {
          final double screenHeight = MediaQuery.of(context).size.height;
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 12.0, bottom: 8.0, right: 8.0),
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
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            FadeRoute(
                              page: FullScreenLatestPhoto(
                                  index: i, displayedUpdates: displayedUpdates),
                            ),
                          ),
                          child: displayedUpdates[i],
                        );
                      },
                      height: screenHeight / 3,
                      viewportFraction: 0.9,
                      enableInfiniteScroll:
                          allPostType.length > 1 ? true : false,
                      enlargeCenterPage: true,
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
      },
    );
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
    return _hasAccountLinked ? streamCloseByChats() : SizedBox();
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

  showContent() {
    if (_locationLoading) {
      return circularProgress();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          enabledLocationFetchUsers(),
          buildNewLatestPosts()
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
