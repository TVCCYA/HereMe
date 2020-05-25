import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_ad_manager/ad_size.dart';
import 'package:flutter_google_ad_manager/banner.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/linked_account.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/notifications/notification_page.dart';
import 'package:hereme_flutter/settings/choose_account.dart';
import 'package:hereme_flutter/settings/menu_list.dart';
import 'package:hereme_flutter/latest/add_latest.dart';
import 'package:hereme_flutter/latest/all_latest.dart';
import 'package:hereme_flutter/user_profile/edit_profile.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/widgets/latest_post.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewProfile extends StatefulWidget {
  final User user;
  final String locationLabel;

  NewProfile({
    this.user,
    this.locationLabel,
  });
  @override
  _NewProfileState createState() => _NewProfileState(
        user: this.user,
        locationLabel: this.locationLabel,
      );
}

class _NewProfileState extends State<NewProfile> {
  final User user;
  final String locationLabel;

  _NewProfileState({
    this.user,
    this.locationLabel,
  });

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCurrentUser = false;

  bool _isFollowing = false;
  bool _didKnock = false;
  String displayName;
  String username;
  String bio = '';
  int red;
  int green;
  int blue;
  int followersCount;
  String displayedFollowersCount;
  String profileImageUrl;
  String backgroundImageUrl;
  String videoUrl;
  int weeklyVisitsCount;
  String displayedWeeklyCount;
  int totalVisitsCount;
  String displayedTotalCount;

  Color color = kColorOffWhite;
  Color color2 = Colors.white;
  bool showSpinner = false;
  bool backgroundImageLoading = true;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  @override
  void initState() {
    super.initState();
    getFollowers();
    _determinePage();
    if (_isCurrentUser) {
      updateCurrentUserCounts();
    } else {
      checkIfFollowing();
      checkIfKnocked();
    }
  }

  updateCurrentUserCounts() async {
    usersRef.document(currentUser.uid).snapshots().listen((doc) {
      if (this.mounted)
        setState(() {
          weeklyVisitsCount = doc.data['weeklyVisitsCount'];
          totalVisitsCount = doc.data['totalVisitsCount'];

          displayedWeeklyCount =
              NumberFormat.compact().format(weeklyVisitsCount);
          displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
        });
    });
  }

  _getPaletteColor(String backgroundImage) async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      backgroundImage != null
          ? CachedNetworkImageProvider(backgroundImage)
          : CachedNetworkImageProvider(profileImageUrl),
    );
    final muted = generator.mutedColor.color;
    final dominant = generator.dominantColor.color;
    final first = generator.colors.first;
    final last = generator.colors.last;
    if (this.mounted)
      setState(() {
        color = muted != null ? muted : dominant != null ? dominant : first;
        color2 = dominant != null ? dominant : muted != null ? muted : last;
        backgroundImageLoading = false;
      });
  }

  _determinePage() async {
    if (currentUser.uid == user.uid) {
      _getCurrentUserData();
      if (this.mounted)
        setState(() {
          _isCurrentUser = true;
        });
    } else {
      _getUserPageData();
    }
    await configurePushNotifications();
  }

  configurePushNotifications() async {
    final user = await auth.currentUser();
    if (Platform.isIOS) getIOSPermission();
    _firebaseMessaging.getToken().then((token) async {
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

  getIOSPermission() async {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {});
  }

  _getCurrentUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('profileImageUrl');
    String name = prefs.getString('username');
    String background = prefs.getString('backgroundImageUrl');
    if (this.mounted)
      setState(() {
        profileImageUrl = url;
        username = name;
        displayName = currentUser.displayName;
        red = currentUser.red;
        green = currentUser.green;
        blue = currentUser.blue;
        backgroundImageUrl = background;
        videoUrl = currentUser.videoUrl;
        bio = currentUser.bio;
      });
    await _getPaletteColor(backgroundImageUrl);
//    if(videoUrl != null || videoUrl != '') initializeFavVid();
  }

  _getUserPageData() async {
    await usersRef.document(user.uid).get().then((doc) {
      User user = User.fromDocument(doc);
      if (this.mounted)
        setState(() {
          _isCurrentUser = false;
          username = user.username;
          displayName = user.displayName;
          red = user.red;
          green = user.green;
          blue = user.blue;
          profileImageUrl = user.profileImageUrl;
          weeklyVisitsCount = user.weeklyVisitsCount + 1;
          totalVisitsCount = user.totalVisitsCount + 1;
          backgroundImageUrl = user.backgroundImageUrl;
          videoUrl = user.videoUrl;
          bio = user.bio;

          displayedWeeklyCount =
              NumberFormat.compact().format(weeklyVisitsCount);
          displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
        });
      usersRef.document(user.uid).updateData({
        'weeklyVisitsCount': user.weeklyVisitsCount + 1,
        'totalVisitsCount': user.totalVisitsCount + 1,
      });
    });
    await _getPaletteColor(backgroundImageUrl);
//    if(videoUrl != null) initializeFavVid();
  }

  _followUser() {
    print('following');
    setState(() {
      _isFollowing = true;
    });

    followersRef
        .document(user.uid)
        .collection('users')
        .document(currentUser.uid)
        .setData({'creationDate': DateTime.now().millisecondsSinceEpoch});

    followingRef
        .document(currentUser.uid)
        .collection('users')
        .document(user.uid)
        .setData({}).whenComplete(() {
      getFollowers();
    });
  }

  _unfollowUser() {
    print('unfollow');
    setState(() {
      _isFollowing = false;
    });

    followersRef
        .document(user.uid)
        .collection('users')
        .document(currentUser.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUser.uid)
        .collection('users')
        .document(user.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }).whenComplete(() {
      getFollowers();
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(user.uid)
        .collection('users')
        .getDocuments();
    setState(() {
      followersCount = snapshot.documents.length;
      displayedFollowersCount = NumberFormat.compact().format(followersCount);
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(user.uid)
        .collection('users')
        .document(currentUser.uid)
        .get();
    setState(() {
      _isFollowing = doc.exists;
    });
  }

  checkIfKnocked() async {
    DocumentSnapshot doc = await knocksRef
        .document(currentUser.uid)
        .collection('sentKnockTo')
        .document(user.uid)
        .get();
    setState(() {
      _didKnock = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: circularProgress(),
      child: Theme(
        data: kTheme(context),
        child: Scaffold(
          key: _scaffoldKey,
          body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: backgroundImageUrl != null ? color : color2,
                    elevation: 2.0,
                    expandedHeight: screenHeight / 3,
                    floating: true,
                    pinned: true,
                    stretch: true,
                    centerTitle: true,
                    title: appBarTitle(),
                    leading: IconButton(
                      icon: IconShadowWidget(
                        Icon(FontAwesomeIcons.chevronLeft,
                            color: kColorOffWhite, size: 20),
                        shadowColor: kColorBlack62,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: <Widget>[
                      !_isCurrentUser
                          ? IconButton(
                              icon: IconShadowWidget(
                                Icon(
                                  _isFollowing
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  color: kColorOffWhite,
                                  size: 20,
                                ),
                                shadowColor: kColorBlack62.withOpacity(0.5),
                              ),
                              onPressed: () => _isFollowing
                                  ? _unfollowUser()
                                  : _followUser(),
                            )
                          : IconButton(
                              icon: IconShadowWidget(
                                Icon(
                                  FontAwesomeIcons.solidBell,
                                  color: kColorOffWhite,
                                  size: 20,
                                ),
                                shadowColor: kColorBlack62,
                              ),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationPage())),
                            )
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: <Widget>[
                          backgroundImageLoading
                              ? Container(color: color)
                              : backgroundImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: backgroundImageUrl,
                                      width: screenWidth,
                                      height: screenHeight / 2,
                                      fit: BoxFit.cover,
                                      fadeInDuration: Duration(seconds: 1),
                                    )
                                  : Container(
                              decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomLeft,
                                colors: [
                                  color,
                                  color2,
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          FadeRoute(
                                              page: ProfileImageFullScreen(
                                                  profileImageUrl))),
                                      child: cachedUserResultImage(
                                          profileImageUrl != null
                                              ? profileImageUrl
                                              : '',
                                          screenWidth / 5,
                                          true)),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          width: screenWidth -
                                              (screenWidth / 5) -
                                              10,
                                          child: Text(
                                            username ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: kUsernameTextStyle,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.mapMarkerAlt,
                                              color: kColorDarkThistle,
                                              size: 14.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Container(
                                              width: screenWidth -
                                                  (screenWidth / 5) -
                                                  30,
                                              child: Text(
                                                locationLabel ?? 'Around',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style:
                                                    kAppBarTextStyle.copyWith(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      blurRadius: 3.0,
                                                      color: kColorBlack62,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildAbout(screenWidth),
                    buildLinkedAccounts(),
                    buildLatestPosts(),
                  ],
                ),
              )),
          floatingActionButton: _isCurrentUser
              ? FloatingActionButton(
                  elevation: 2.0,
                  onPressed: () => _addContent(),
                  child: Icon(FontAwesomeIcons.plus),
                  backgroundColor: color,
                )
              : SizedBox(),
        ),
      ),
    );
  }

  showAd() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        color: Colors.transparent,
        height: 50.0,
        child: Center(
          child: DFPBanner(
            isDevelop: false,
            adUnitId: Platform.isIOS ? 'ca-app-pub-5239326709670732/4791964351' : 'ca-app-pub-5239326709670732/5712121097',
            adSize: DFPAdSize.BANNER,
            onAdLoaded: () {
              print('Banner onAdLoaded');
            },
            onAdFailedToLoad: (errorCode) {
              print('Banner onAdFailedToLoad: errorCode:$errorCode');
            },
            onAdOpened: () {
              print('Banner onAdOpened');
            },
            onAdClosed: () {
              print('Banner onAdClosed');
            },
            onAdLeftApplication: () {
              print('Banner onAdLeftApplication');
            },
          ),
        ),
      ),
    );
  }

  Text appBarTitle() {
    return Text(
      displayName ?? username ?? '',
      style: kAppBarTextStyle.copyWith(
        color: Colors.white,
        shadows: <Shadow>[
          Shadow(
            blurRadius: 3.0,
            color: kColorBlack62,
          ),
        ],
      ),
    );
  }

  buildAbout(double screenWidth) {
    return Theme(
      data: kTheme(context),
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('$displayedTotalCount profile views',
                    style: kDefaultTextStyle.copyWith(color: kColorLightGray)),
                GestureDetector(
                  child: Icon(FontAwesomeIcons.ellipsisH, size: 20),
                  onTap: () => _isCurrentUser
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListPage()),
                        )
                      : _reportBlockSettings(),
                ),
              ],
            ),
            _isCurrentUser
                ? Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text('$displayedFollowersCount profile likes',
                        style:
                            kDefaultTextStyle.copyWith(color: kColorLightGray)),
                  )
                : SizedBox(),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: _isCurrentUser ? Row(
                children: <Widget>[
                  Container(
                    height: 30,
                    child: ReusableRoundedCornerButton(
                      text: 'Edit Profile',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile(color: color, color2: color2)),
                        );
                        result != null ? await _getCurrentUserData() : print('nothing happened');
                      },
                      width: 40,
                      backgroundColor: Colors.transparent,
                      textColor: kColorLightGray,
                    ),
                  ),
//                  SizedBox(width: 8.0),
//                  Container(
//                    height: 30,
//                    child: ReusableRoundedCornerButton(
//                      text: 'Host Chat',
//                      onPressed: () async {
//                        final result = await Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) => AddLiveChat()),
//                        );
//                        result != null ? await _getCurrentUserData() : print('nothing happened');
//                      },
//                      width: 40,
//                      backgroundColor: Colors.transparent,
//                      textColor: kColorRed,
//                    ),
//                  ),
                ],
              )
                  : Container(
                height: 30,
                child: ReusableRoundedCornerButton(
                  text: _didKnock ? 'Knocked' : 'Knock',
                  onPressed: () =>_handleKnock(),
                  width: 40,
                  backgroundColor: Colors.transparent,
                  textColor: kColorLightGray,
                ),
              ),
            ),
            bio == ''
                ? SizedBox()
                : Container(
                    width: screenWidth - 55,
                    child: Text(
                      bio ?? '',
                      style: kDefaultTextStyle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  buildLinkedAccounts() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ReusableHeaderLabel('Links'),
          _isCurrentUser
              ? StreamBuilder<QuerySnapshot>(
                  stream: socialMediasRef
                      .document(currentUser.uid)
                      .collection('socials')
                      .orderBy('creationDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
                    final accounts = snapshot.data.documents;
                    List<LinkedAccount> displayedAccounts = [];
                    for (var account in accounts) {
                      account.data.forEach(
                        (key, value) {
                          if (key.contains('Username')) {
                            final iconString = key;
                            final accountUsername = value;
                            final url = account.data['url'];
                            final linkId = account.data['linkId'];

                            _determineUrl(accountUsername, iconString, url);

                            final displayedAccount = LinkedAccount(
                              accountUsername: accountUsername,
                              accountUrl: url,
                              iconString: iconString,
                              onTap: () {
                                _linksActionSheet(
                                  context,
                                  accountUsername,
                                  iconString,
                                  url,
                                  linkId,
                                );
                              },
                            );
                            displayedAccounts.add(displayedAccount);
                          }
                        },
                      );
                    }
                    if (displayedAccounts.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: displayedAccounts,
                      );
                    } else {
                      _updateFirestoreHasAccountLinked();
                      return ReusableBottomActionSheetListTile(
                        iconData: FontAwesomeIcons.link,
                        title: 'Link Account',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChooseAccount()),
                          );
                        },
                      );
                    }
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: socialMediasRef
                      .document(user.uid)
                      .collection('socials')
                      .orderBy('creationDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
                    final accounts = snapshot.data.documents;
                    List<LinkedAccount> displayedAccounts = [];
                    for (var account in accounts) {
                      account.data.forEach(
                        (key, value) {
                          if (key.contains('Username')) {
                            final iconString = key;
                            final accountUsername = value;
                            final url = account.data['url'];
                            final linkId = account.data['linkId'];

                            _determineUrl(accountUsername, iconString, url);

                            final displayedAccount = LinkedAccount(
                              accountUsername: accountUsername,
                              accountUrl: url,
                              iconString: iconString,
                              onTap: () {
                                _linksActionSheet(
                                  context,
                                  accountUsername,
                                  iconString,
                                  url,
                                  linkId,
                                );
                              },
                            );
                            displayedAccounts.add(displayedAccount);
                          }
                        },
                      );
                    }
                    if (displayedAccounts.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: displayedAccounts,
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                        child: Text(
                          'No Accounts Linked',
                          style: kDefaultTextStyle,
                        ),
                      );
                    }
                  },
                ),
          showAd()
        ],
      ),
    );
  }

  buildLatestPosts() {
    int postLimit = 5;
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ReusableHeaderLabel('Latest'),
          _isCurrentUser
              ? StreamBuilder<QuerySnapshot>(
                  stream: latestRef
                      .document(currentUser.uid)
                      .collection('posts')
                      .orderBy('creationDate', descending: true)
                      .limit(postLimit)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
                    final latest = snapshot.data.documents;
                    List<ProfileLatestPost> displayedLatest = [];
                    List<ProfileLatestPost> displayedPhotos = [];
                    for (var post in latest) {
                      final String photoUrl = post.data['photoUrl'];
                      final String title = post.data['title'];
                      final int creationDate = post.data['creationDate'];
                      final String type = post.data['type'];
                      final String id = post.data['id'];
                      final dynamic likes = post.data['likes'];

                      final displayedPost = ProfileLatestPost(
                        photoUrl: photoUrl,
                        title: title,
                        creationDate: creationDate,
                        type: type,
                        uid: currentUser.uid,
                        id: id,
                        displayName:
                            currentUser.displayName ?? currentUser.username,
                        likes: likes ?? {},
                        red: red,
                        green: green,
                        blue: blue,
                      );
                      displayedLatest.add(displayedPost);
                      if (type == 'photo') {
                        displayedPhotos.add(displayedPost);
                      }
                    }
                    if (displayedLatest.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListView.builder(
                            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayedLatest.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () => displayedPhotos.isNotEmpty ? Navigator.push(
                                  context,
                                  FadeRoute(
                                    page: FullScreenLatestPhoto(
                                        index: displayedPhotos.indexOf(displayedLatest[i]),
                                        displayedLatest: displayedPhotos),
                                  ),
                                ) : print('do nothing'),
                                child: displayedLatest[i],
                              );
                            },
                          ),
                          displayedLatest.length == postLimit ? Center(
                            child: Container(
                              height: 30,
                              child: ReusableRoundedCornerButton(
                                text: 'View All',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllLatest(
                                      uid: user.uid,
                                      displayName: displayName ?? username,
                                      red: red,
                                      green: green,
                                      blue: blue,
                                    ),
                                  ),
                                ),
                                width: 40,
                                backgroundColor: Colors.transparent,
                                textColor: kColorLightGray,
                              ),
                            ),
                          ) : SizedBox(),
                        ],
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Center(
                          child: Text(
                            'No Posts Yet',
                            style: kDefaultTextStyle,
                          ),
                        ),
                      );
                    }
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: latestRef
                      .document(user.uid)
                      .collection('posts')
                      .orderBy('creationDate', descending: true)
                      .limit(postLimit)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
                    final latest = snapshot.data.documents;
                    List<ProfileLatestPost> displayedLatest = [];
                    List<ProfileLatestPost> displayedPhotos = [];
                    for (var post in latest) {
                      final String photoUrl = post.data['photoUrl'];
                      final String title = post.data['title'];
                      final int creationDate = post.data['creationDate'];
                      final String type = post.data['type'];
                      final String id = post.data['id'];
                      final dynamic likes = post.data['likes'];

                      final displayedPost = ProfileLatestPost(
                        photoUrl: photoUrl,
                        title: title,
                        creationDate: creationDate,
                        type: type,
                        uid: user.uid,
                        id: id,
                        displayName: displayName ?? username,
                        likes: likes ?? {},
                        red: red,
                        green: green,
                        blue: blue,
                      );
                      displayedLatest.add(displayedPost);
                      if (type == 'photo') {
                        displayedPhotos.add(displayedPost);
                      }
                    }
                    if (displayedLatest.isNotEmpty) {
                      return Column(
                        children: <Widget>[
                          ListView.builder(
                            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayedLatest.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () => displayedPhotos.isNotEmpty ? Navigator.push(
                                  context,
                                  FadeRoute(
                                    page: FullScreenLatestPhoto(
                                        index: displayedPhotos.indexOf(displayedLatest[i]),
                                        displayedLatest: displayedPhotos),
                                  ),
                                ) : print('do nothing'),
                                child: displayedLatest[i],
                              );
                            },
                          ),
                          displayedLatest.length == postLimit ? Center(
                            child: Container(
                              height: 30,
                              child: ReusableRoundedCornerButton(
                                text: 'View All',
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllLatest(
                                            uid: user.uid,
                                            displayName:
                                                displayName ?? username,
                                            red: red,
                                            green: green,
                                            blue: blue,
                                        ),
                                    ),
                                ),
                                width: 40,
                                backgroundColor: Colors.transparent,
                                textColor: kColorLightGray,
                              ),
                            ),
                          ) : SizedBox(),
                        ],
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Center(
                          child: Text(
                            'No Posts Yet',
                            style: kDefaultTextStyle,
                          ),
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  _handleKnock() {
    final ref = knocksRef
        .document(user.uid)
        .collection('receivedKnockFrom')
        .document(currentUser.uid);
    final newRef = ref.get();
    newRef.then((doc) {
      if (!doc.exists && user.uid != null) {
        _sendKnock(ref);
        if (this.mounted)
          setState(() {
            _didKnock = true;
          });
      } else {
        kShowSnackbar(
          key: _scaffoldKey,
          text: 'Already Knocked $username',
          backgroundColor: kColorRed,
        );
      }
    });
  }

  _sendKnock(DocumentReference ref) {
    int creationDate = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> knockData = <String, dynamic>{
      'creationDate': creationDate,
    };
    ref.setData(knockData).whenComplete(() {
      _updateSentKnockTo();
      kShowSnackbar(
        key: _scaffoldKey,
        text: 'Successfully Sent Knock',
        backgroundColor: kColorGreen,
      );
    }).catchError((e) => kShowAlert(
        context: context,
        title: 'Knock Failed',
        desc: 'Unable to knock $username, please try again later',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
        color: kColorRed));
  }

  _updateSentKnockTo() {
    final creationDate = DateTime.now().millisecondsSinceEpoch;
    knocksRef
        .document(currentUser.uid)
        .collection('sentKnockTo')
        .document(user.uid)
        .setData({
      'creationDate': creationDate,
    }).whenComplete(() {
      _removeSentKnockTo(user.uid, currentUser.uid);
    }).whenComplete(() {
      _removeKnock(user.uid);
    });
  }

  _removeSentKnockTo(String uid1, String uid2) {
    knocksRef
        .document(uid1)
        .collection('sentKnockTo')
        .document(uid2)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _removeKnock(String uid) {
    knocksRef
        .document(currentUser.uid)
        .collection('receivedKnockFrom')
        .document(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _updateFirestoreHasAccountLinked() {
    usersRef.document(currentUser.uid).updateData({
      'hasAccountLinked': false,
    });
    currentUser.hasAccountLinked = false;
  }

  _linksActionSheet(BuildContext context, String accountUsername,
      String iconString, String url, String linkId) {
    String platform;
    for (var platformString
        in _determineUrl(accountUsername, iconString, url).keys) {
      platform = platformString;
    }
    List<ReusableBottomActionSheetListTile> sheets = [];
    _isCurrentUser
        ? sheets.add(
            ReusableBottomActionSheetListTile(
              title: 'Unlink $accountUsername',
              iconData: FontAwesomeIcons.unlink,
              color: kColorRed,
              onTap: () {
                kShowAlert(
                  context: context,
                  title: "Unlink Account?",
                  desc: "Are you sure you want to unlink $accountUsername?",
                  buttonText: "Unlink",
                  onPressed: () {
                    Navigator.pop(context);
                    kHandleRemoveDataAtId(
                        linkId, currentUser.uid, 'socialMedias', 'socials');
                    kHandleRemoveDataAtId(
                        linkId, currentUser.uid, 'latest', 'posts');
                    Navigator.pop(context);
                  },
                  color: kColorRed,
                );
              },
            ),
          )
        : SizedBox();
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Open in $platform',
        iconData: FontAwesomeIcons.externalLinkAlt,
        onTap: () async {
          _launchUrl(accountUsername, iconString, url);
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Copy to Clipboard',
        iconData: FontAwesomeIcons.clipboard,
        onTap: () {
          Clipboard.setData(ClipboardData(text: accountUsername));
          Navigator.pop(context);
          kShowSnackbar(
            key: _scaffoldKey,
            text: 'Copied $accountUsername',
            backgroundColor: kColorGreen,
          );
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel',
        iconData: FontAwesomeIcons.times,
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _launchUrl(String accountUsername, String iconString, String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      kShowSnackbar(
          key: _scaffoldKey,
          text: 'Whoops, unable to open in app',
          backgroundColor: kColorRed);
    }
  }

  Map<String, String> _determineUrl(
      String accountUsername, String iconString, String url) {
    final icon = iconString;
    Map<String, String> retMap;

    if (icon.contains('twitter')) {
      retMap = {'Twitter': url};
    } else if (icon.contains('snapchat')) {
      retMap = {'Snapchat': url};
    } else if (icon.contains('instagram')) {
      retMap = {'Instagram': url};
    } else if (icon.contains('youtube')) {
      retMap = {'YouTube': url};
    } else if (icon.contains('soundcloud')) {
      retMap = {'SoundCloud': url};
    } else if (icon.contains('venmo')) {
      retMap = {'Venmo': url};
    } else if (icon.contains('spotify')) {
      retMap = {'Spotify': url};
    } else if (icon.contains('twitch')) {
      retMap = {'Twitch': url};
    } else if (icon.contains('tumblr')) {
      retMap = {'Tumblr': url};
    } else if (icon.contains('reddit')) {
      retMap = {'Reddit': url};
    } else if (icon.contains('facebook')) {
      retMap = {'Facebook': url};
    } else if (icon.contains('website')) {
      retMap = {'Your Website': url};
    } else if (icon.contains('tiktok')) {
      retMap = {'TikTok': url};
    } else if (icon.contains('pinterest')) {
      retMap = {'Pinterest': url};
    } else if (icon.contains('etsy')) {
      retMap = {'Etsy': url};
    } else if (icon.contains('cashapp')) {
      retMap = {'Cash App': url};
    } else {
      retMap = {'Browser': url};
    }
    return retMap;
  }

  _addContent() {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.link,
        title: 'Link Account',
        color: kColorRed,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ChooseAccount()),
          );
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.newspaper,
        title: 'Add Latest',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddLatest()));
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportBlockSettings() {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.flag,
        title: 'Report',
        color: kColorRed,
        onTap: () {
          _reasonToReport();
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.ban,
        title: 'Block',
        color: kColorRed,
        onTap: () {
          kConfirmBlock(context, username, user.uid);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reasonToReport() {
    Navigator.pop(context);
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.mehRollingEyes,
        title: 'Spam Account',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Spam');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.angry,
        title: 'Innappropriate',
        color: kColorRed,
        onTap: () {
          _reportUser(context, 'Innappropriate');
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.times,
        title: 'Cancel',
        onTap: () => Navigator.pop(context),
      ),
    );
    kActionSheet(context, sheets);
  }

  _reportUser(BuildContext context, String reason) {
    bool canReport = user.uid != null;
    canReport
        ? reportedUsersRef.document(user.uid).setData({
            'uid': user.uid,
            'username': username,
            'displayName': displayName,
            'reason': reason,
            'reportedByUid': currentUser.uid,
          }).whenComplete(() {
            kShowAlert(
              context: context,
              title: 'Successfully Reported',
              desc: 'Thank you for making HereMe a better place',
              buttonText: 'Dismiss',
              onPressed: () => Navigator.pop(context),
              color: kColorBlue,
            );
          })
        : kShowAlert(
            context: context,
            title: 'Whoops',
            desc: 'Unable to report at this time',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          );
  }
}
