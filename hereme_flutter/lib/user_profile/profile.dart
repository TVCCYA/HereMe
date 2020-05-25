import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/live_chat/live_chat.dart';
import 'package:hereme_flutter/live_chat/live_chat_screen.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/live_chat/add_live_chat.dart';
import 'package:hereme_flutter/models/knock.dart';
import 'package:hereme_flutter/models/linked_account.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/latest/add_latest.dart';
import 'package:hereme_flutter/settings/choose_account.dart';
import 'package:hereme_flutter/latest/all_latest.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/utils/reusable_header_label.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'package:hereme_flutter/widgets/activity_feed_item.dart';
import 'package:hereme_flutter/widgets/latest_post.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hereme_flutter/settings//menu_list.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';

final reportedUsersRef = Firestore.instance.collection('reportedUsers');

class Profile extends StatefulWidget {
  final User user;
  final String locationLabel;

  Profile({
    this.user,
    this.locationLabel,
  });

  @override
  _ProfileState createState() => _ProfileState(
    user: this.user,
    locationLabel: this.locationLabel,
  );
}

class _ProfileState extends State<Profile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showSpinner = false;
  bool _isCurrentUser = false;
  bool _isFollowing = false;
  String username;
  String displayName;
  String userUid;
  int red;
  int green;
  int blue;
  int followersCount;
  String displayedFollowersCount;
  String profileImageUrl;
  String backgroundImageUrl;
  File mediaFile;
  String videoUrl;
  int weeklyVisitsCount;
  String displayedWeeklyCount;
  int totalVisitsCount;
  String displayedTotalCount;
  final String currentUserUid = currentUser?.uid;

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  final User user;
  final String locationLabel;
  _ProfileState({this.user, this.locationLabel});

  @override
  void initState() {
    super.initState();
    _determinePage();
    getFollowers();
    if (_isCurrentUser) {
      updateCurrentUserCounts();
    } else {
      checkIfFollowing();
    }
  }

  initializeFavVid() {
    _controller = VideoPlayerController.network(
      videoUrl,
    );
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (this.mounted)
        setState(() {
          _controller.play();
          _controller.setVolume(0.0);
        });
    });
    _controller.setLooping(true);
  }

  Future<Size> _calculateImageDimension(String url) {
    Completer<Size> completer = Completer();
    Image image = Image.network(url);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  updateCurrentUserCounts() async {
    usersRef.document(currentUserUid).snapshots().listen((doc) {
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

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Container(
            decoration: backgroundImageUrl != null ? BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(backgroundImageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(kColorBlack62.withOpacity(0.35), BlendMode.multiply)
                ),
                color: Colors.white
            ) : BoxDecoration(
              color: Colors.white,
            )
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            brightness: Brightness.light,
            backgroundColor: backgroundImageUrl != null ? Colors.white.withOpacity(0.75) : Colors.white,
            title: _isCurrentUser ? FlatButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateDisplayName())),
              child: appBarTitle(),
              splashColor: kColorExtraLightGray,
              highlightColor: Colors.transparent,
            ) : appBarTitle(),
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: kColorBlack62),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.ellipsisV, color: kColorBlack62),
                onPressed: () {
                  _isCurrentUser ? _quickSettings() : _reportBlockSettings();
                },
                splashColor: kColorExtraLightGray,
                highlightColor: Colors.transparent,
              )
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: circularProgress(),
            child: SafeArea(
              child: Theme(
                data: kTheme(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildHeader(screenHeight, screenWidth),
                      buildFeedUpdates(screenHeight, screenWidth),
                      buildLinkedAccounts(),
                      buildBottomFavorites(screenWidth),
                      buildFooterProfileLikes(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Text appBarTitle() {
    return Text(
      displayName ?? username ?? '',
      style: kAppBarTextStyle.copyWith(
        color:
        Color.fromRGBO(red ?? 71, green ?? 71, blue ?? 71, 1.0),
      ),
    );
  }

  buildHeader(double screenHeight, double screenWidth) {
    double topProfileHeight = screenHeight / 4;
    double topHalf = topProfileHeight * 0.75;
    double profileImageSize = topHalf * 0.75;
    double topHalfContainerSize = screenWidth - profileImageSize - 50;
    return Padding(
      padding: EdgeInsets.only(
          left: 24.0, right: 24.0, bottom: 12.0),
      child: Column(
        children: <Widget>[
          Container(
            height: topHalf,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () => _isCurrentUser
                      ? _changeUserPhoto(true)
                      : _fullScreenProfileImage(),
                  child: cachedUserResultImage(profileImageUrl != null ? profileImageUrl : '', profileImageSize, true),
                ),
//                ReusableProfileCard(
//                  imageUrl: profileImageUrl,
//                  cardSize: profileImageSize,
//                  onTap: () => _isCurrentUser
//                      ? _changeUserPhoto(true)
//                      : _fullScreenProfileImage(),
//                ),
                Container(
                  height: profileImageSize,
                  width: topHalfContainerSize,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TopProfileHeaderContainer(
                          text: username ?? '',
                          fontSize: 18.0,
                          padding: 8.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: kColorExtraLightGray),
                              color: Colors.white),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.mapMarkerAlt,
                                color: kColorDarkThistle,
                                size: 14.0,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                locationLabel ?? 'Around',
                                style:
                                kAppBarTextStyle.copyWith(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: _isCurrentUser
                              ? <Widget>[
                            TopProfileHeaderContainer(
                                text: 'Profile Views:',
                                fontSize: 16.0,
                                padding: 8.0),
                            SizedBox(width: 6.0),
                            TopProfileHeaderContainer(
                                text: displayedTotalCount ?? '0',
                                fontSize: 16.0,
                                padding: 4.0),
                          ]
                              : <Widget>[],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            child: _isCurrentUser
                ? ReusableRoundedCornerButton(
              text: 'Change Background',
              onPressed: () => _changeUserPhoto(false),
              width: screenWidth,
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ReusableRoundedCornerButton(
                  text: _isFollowing ? 'Liked' : 'Like',
                  onPressed: () =>
                  _isFollowing ? _unfollowUser() : _followUser(),
                  width: screenWidth / 2.5,
                  textColor:
                  _isFollowing ? kColorBlack62 : Colors.white,
                  backgroundColor:
                  _isFollowing ? Colors.white : kColorBlue,
                  splashColor:
                  _isFollowing ? Colors.white : kColorDarkBlue,
                ),
                ReusableRoundedCornerButton(
                  text: 'Knock',
                  onPressed: () => {
                    kShowAlertMultiButtons(
                      context: context,
                      title: 'Knock Knock',
                      desc: 'Did you mean to Knock $username?',
                      buttonText1: 'Yes',
                      color1: kColorGreen,
                      buttonText2: 'Cancel',
                      color2: kColorLightGray,
                      onPressed1: () {
                        _handleKnock(
                          uid: userUid,
                          username: username,
                          profileImageUrl: profileImageUrl,
                        );
                        Navigator.pop(context);
                      },
                      onPressed2: () => Navigator.pop(context),
                    )
                  },
                  width: screenWidth / 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _followUser() {
    print('following');
    setState(() {
      _isFollowing = true;
    });

    followersRef
        .document(user.uid)
        .collection('users')
        .document(currentUserUid)
        .setData({});

    followingRef
        .document(currentUserUid)
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
        .document(currentUserUid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUserUid)
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

  buildFeedUpdates(double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
          left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kColorExtraLightGray),
          color: Colors.white.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 12.0, bottom: 4.0),
          child: buildUpdatePosts(),
        ),
      ),
    );
  }

  buildUpdatePosts() {
    if (_isCurrentUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: latestRef
                .document(currentUserUid)
                .collection('posts')
                .orderBy('creationDate', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              final updates = snapshot.data.documents;
              List<ProfileLatestPost> displayedUpdates = [];
              List<ProfileLatestPost> displayedPhotos = [];
              for (var post in updates) {

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
                  uid: currentUserUid,
                  id: id,
                  displayName: displayName ?? username,
                  likes: likes ?? {},
                );
                displayedUpdates
                    .add(displayedPost);
                if (type == 'photo') {
                  displayedPhotos.add(displayedPost);
                }
              }
              if (displayedUpdates.isNotEmpty) {
                return Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text('View All',
                              style: kAppBarTextStyle.copyWith(
                                  fontSize: 16.0, color: kColorRed)),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllLatest(uid: currentUserUid, displayName: displayName ?? username))),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: displayedUpdates.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () =>
                              Navigator.push(
                                context,
                                FadeRoute(
                                  page: FullScreenLatestPhoto(index: i, displayedLatest: displayedPhotos),
                                ),
                              ),
                          child: displayedUpdates[i],
                        );
                      },
                    ),
                  ],
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                      top: 2.0, bottom: 8.0),
                  child: Text(
                    'No Posts Yet',
                    style: kDefaultTextStyle,
                  ),
                );
              }
            },
          ),
          SizedBox(height: 4.0),
          ButtonTheme(
            height: 40,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent)),
              color: kColorBlue,
              child: Center(
                child: Text(
                  'Add Update',
                  style: kDefaultTextStyle.copyWith(color: Colors.white),
                ),
              ),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddLatest())),
              splashColor: kColorDarkBlue,
              highlightColor: Colors.transparent,
            ),
          )
        ],
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: latestRef
            .document(userUid)
            .collection('posts')
            .orderBy('creationDate', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final updates = snapshot.data.documents;
          List<ProfileLatestPost> displayedUpdates = [];
          List<ProfileLatestPost> displayedPhotos = [];
          for (var post in updates) {

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
              uid: userUid,
              id: id,
              displayName: displayName ?? username,
              likes: likes ?? {},
            );
            displayedUpdates
                .add(displayedPost);
            if (type == 'photo') {
              displayedPhotos.add(displayedPost);
            }
          }
          if (displayedUpdates.isNotEmpty) {
            return Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Text('View All',
                          style: kAppBarTextStyle.copyWith(
                              fontSize: 16.0, color: kColorRed)),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllLatest(uid: userUid, displayName: displayName ?? username))),
                  ),
                ),
                SizedBox(height: 8.0),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: displayedUpdates.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () =>
                          Navigator.push(
                            context,
                            FadeRoute(
                              page: FullScreenLatestPhoto(index: i, displayedLatest: displayedPhotos),
                            ),
                          ),
                      child: displayedUpdates[i],
                    );
                  },
                ),
//                Column(children: displayedUpdates),
              ],
            );
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
    }
  }

  buildLinkedAccounts() {
    return Padding(padding: EdgeInsets.only(
        left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kColorExtraLightGray),
          color: Colors.white.withOpacity(0.9),
        ),
        child: ExpansionTile(
          backgroundColor: Colors.white.withOpacity(0.9),
          initiallyExpanded: true,
          title: ReusableHeaderLabel('Links'),
          children: <Widget>[
            _isCurrentUser
                ? StreamBuilder<QuerySnapshot>(
              stream: socialMediasRef
                  .document(currentUserUid)
                  .collection('socials')
                  .orderBy('creationDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                final accounts =
                    snapshot.data.documents;
                List<LinkedAccount> displayedAccounts =
                [];
                for (var account in accounts) {
                  account.data.forEach(
                        (key, value) {
                      if (key.contains('Username')) {
                        final iconString = key;
                        final accountUsername = value;
                        final url = account.data['url'];
                        final linkId =
                        account.data['linkId'];

                        _determineUrl(accountUsername,
                            iconString, url);

                        final displayedAccount =
                        LinkedAccount(
                          accountUsername:
                          accountUsername,
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
                        displayedAccounts
                            .add(displayedAccount);
                      }
                    },
                  );
                }
                if (displayedAccounts.isNotEmpty) {
                  return Column(
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
            ) : StreamBuilder<QuerySnapshot>(
              stream: socialMediasRef
                  .document(userUid)
                  .collection('socials')
                  .orderBy('creationDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                final accounts =
                    snapshot.data.documents;
                List<LinkedAccount> displayedAccounts =
                [];
                for (var account in accounts) {
                  account.data.forEach(
                        (key, value) {
                      if (key.contains('Username')) {
                        final iconString = key;
                        final accountUsername = value;
                        final url = account.data['url'];
                        final linkId =
                        account.data['linkId'];

                        _determineUrl(accountUsername,
                            iconString, url);

                        final displayedAccount =
                        LinkedAccount(
                          accountUsername:
                          accountUsername,
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
                        displayedAccounts
                            .add(displayedAccount);
                      }
                    },
                  );
                }
                if (displayedAccounts.isNotEmpty) {
                  return ReusableContentContainer(
                    content: displayedAccounts,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0),
                    child: Text(
                      'No Accounts Linked',
                      style: kDefaultTextStyle,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  buildBottomFavorites(double screenWidth) {
    return
      Padding(
        padding: EdgeInsets.only(
            left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildLeftFavorites(screenWidth),
            buildRightFavorites(screenWidth),
          ],
        ),
      );
  }

  buildRightFavorites(double screenWidth) {
    final double width = (screenWidth / 3.5);
    final double squareWidth = (screenWidth / 2.75);
    final double height = (screenWidth / 3.5) * 2 + 12;
    return Column(
      children: <Widget>[
        Container(
          height: height,
          width: squareWidth,
//          color: kColorExtraLightGray,
          child: videoUrl == null || videoUrl == '' ? FlatButton(
            child: Icon(FontAwesomeIcons.photoVideo, size: 25, color: kColorLightGray),
            color: kColorExtraLightGray,
            splashColor: Colors.white,
            highlightColor: Colors.transparent,
            onPressed: () => _photoVideoActionSheet(context),
          ) : new Stack(
            children: <Widget> [
              Container(
                height: height,
                width: squareWidth,
                child: buildVideo(),
              ),
              Container(
                  height: height,
                  width: squareWidth,
                  alignment: Alignment(-squareWidth * .015, -1.0),
                  child: FlatButton(
                    child: Icon(FontAwesomeIcons.cog, color: kColorLightGray),
                    onPressed: () => _photoVideoActionSheet(context),
                  )
              ),
              Container(
                  height: height,
                  width: squareWidth,
                  alignment: Alignment(squareWidth * .015, -1.0),
                  child: FlatButton(
                    child: vidVolumeIcon(),
                    onPressed: () => muteVideo(),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  )
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: width,
          width: squareWidth,
          color: kColorExtraLightGray,
          child: FlatButton(
            child: Icon(FontAwesomeIcons.music, size: 25, color: kColorLightGray),
            onPressed: () => print('music add'),
            splashColor: Colors.white,
            highlightColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  muteVideo() {
    setState(() {
      _controller.value.volume == 0.0 ? _controller.setVolume(0.5) : _controller.setVolume(0.0);
      vidVolumeIcon();
    });
  }

  Icon vidVolumeIcon() {
    if(_controller.value.volume == 0.0) {
      return Icon(FontAwesomeIcons.volumeMute, size: 25, color: kColorLightGray);
    } else {
      return Icon(FontAwesomeIcons.volumeUp, size: 25, color: kColorLightGray);
    }
  }

  buildLeftFavorites(double screenWidth) {
    final double width = (screenWidth / 3.5);
    return Container(
      height: width * 3 + 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: width,
            width: width,
            color: kColorExtraLightGray,
            child: FlatButton(
              child: Icon(FontAwesomeIcons.userAlt, size: 25, color: kColorLightGray),
              onPressed: () => _favUserActionSheet(context),
              splashColor: Colors.white,
              highlightColor: Colors.transparent,
            ),
          ),
          Container(
            height: width,
            width: width,
            color: kColorExtraLightGray,
            child: FlatButton(
              child: Icon(FontAwesomeIcons.userAlt, size: 25, color: kColorLightGray),
              onPressed: () => _favUserActionSheet(context),
              splashColor: Colors.white,
              highlightColor: Colors.transparent,
            ),
          ),
          Container(
            height: width,
            width: width,
            color: kColorExtraLightGray,
            child: FlatButton(
              child: Icon(FontAwesomeIcons.userAlt, size: 25, color: kColorLightGray),
              onPressed: () => _favUserActionSheet(context),
              splashColor: Colors.white,
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  buildVideo() {
    double screenHeight = MediaQuery.of(context).size.height / 3.5;
    double screenWidth = MediaQuery.of(context).size.width / 3.5;
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              if (this.mounted)
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                    _controller.setVolume(0.5);
                  }
                });
            },
            child: AspectRatio(
              aspectRatio: screenHeight / screenWidth,
              child: VideoPlayer(_controller),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  buildFooterProfileLikes() {
    return Padding(
      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Center(
        child: TopProfileHeaderContainer(
          text: 'Profile Likes: $displayedFollowersCount',
          fontSize: 18.0,
          padding: 8.0,
        ),
      ),
    );
  }

  _photoVideoActionSheet(BuildContext context) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    if(videoUrl != null && videoUrl != '') {
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Delete Video',
          iconData: FontAwesomeIcons.video, color: kColorRed,
          onTap: () {
            _deleteVideo();
            Navigator.pop(context);
          },
        ),
      );
    }
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Add Photo',
        iconData: FontAwesomeIcons.solidImage,
        onTap: () async {
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Add Video',
        iconData: FontAwesomeIcons.video,
        onTap: () {
          _openVideoLibrary();
          Navigator.pop(context);
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

  Future _deleteVideo() async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final userReference = Firestore.instance.collection('users').document(currentUserUid);

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });

    _storage.ref().child('profile_video/$currentUserUid').delete();

    userReference.updateData({'videoUrl': ''}).catchError((e) => print(e)).whenComplete(() {
      if (this.mounted)
        setState(() {
          showSpinner = false;
          videoUrl = '';
        });
    }
    );
  }

  _favUserActionSheet(BuildContext context) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Add Friend',
        iconData: FontAwesomeIcons.userPlus,
        onTap: () async {
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Spred Around',
        iconData: FontAwesomeIcons.solidShareSquare,
        onTap: () {
          _handleShare();
          Navigator.pop(context);
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

  _handleShare() {
    Share.share('Spread the word about Spred!');
  }

  _fullScreenProfileImage() {
    Navigator.push(
        context, FadeRoute(page: ProfileImageFullScreen(profileImageUrl)));
  }

  _updateFirestoreHasAccountLinked() {
    usersRef.document(currentUserUid).updateData({
      'hasAccountLinked': false,
    });
  }

  _knocksActionSheet(
      {BuildContext context,
        String uid,
        String username,
        String profileImageUrl}) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Deny Knock',
        iconData: FontAwesomeIcons.ban,
        color: kColorRed,
        onTap: () async {
          _removePendingKnockActivityFeed(uid, currentUserUid);
          _removeKnock(uid);
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Knock back $username?',
        iconData: FontAwesomeIcons.check,
        onTap: () async {
          _handleKnock(
              uid: uid, username: username, profileImageUrl: profileImageUrl);
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Visit Profile',
        iconData: FontAwesomeIcons.doorOpen,
        onTap: () {
          Navigator.pop(context);
          User user = User(uid: uid);
          UserResult result = UserResult(user: user, locationLabel: 'Around');
          result.toProfile(context);
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

  _handleKnock({String uid, String username, String profileImageUrl}) {
    final ref = knocksRef
        .document(uid)
        .collection('receivedKnockFrom')
        .document(currentUserUid);
    final newRef = ref.get();
    newRef.then((doc) {
      if (!doc.exists && uid != null) {
        _sendKnock(ref, uid, username, profileImageUrl);
      } else {
        kShowSnackbar(
          key: _scaffoldKey,
          text: 'Already Knocked $username',
          backgroundColor: kColorRed,
        );
      }
    });
  }

  _sendKnock(DocumentReference ref, String uid, String username,
      String profileImageUrl) {
    int creationDate = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> knockData = <String, dynamic>{
      'uid': currentUserUid,
      'profileImageUrl': currentUser.profileImageUrl,
      'username': currentUser.username,
      'creationDate': creationDate,
    };
    ref.setData(knockData).whenComplete(() {
      _updateSentKnockTo(uid, username, profileImageUrl);
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

  _updateSentKnockTo(String uid, String username, String profileImageUrl) {
    final creationDate = DateTime.now().millisecondsSinceEpoch;
    knocksRef
        .document(currentUserUid)
        .collection('sentKnockTo')
        .document(uid)
        .setData({
      'uid': uid,
      'creationDate': creationDate,
      'username': username,
      'profileImageUrl': profileImageUrl,
    }).whenComplete(() {
      _setPendingKnockActivityFeed(
          uid, username, profileImageUrl, creationDate);
    }).whenComplete(() {
      _removeSentKnockTo(uid, currentUserUid);
    }).whenComplete(() {
      _removePendingKnockActivityFeed(uid, currentUserUid);
    }).whenComplete(() {
      _removeKnock(uid);
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
        .document(currentUserUid)
        .collection('receivedKnockFrom')
        .document(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _setPendingKnockActivityFeed(
      String uid, String username, String profileImageUrl, int creationDate) {
    activityRef
        .document(currentUserUid)
        .collection('feedItems')
        .document(uid)
        .setData({
      'type': 'pendingKnock',
      'uid': uid,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'creationDate': creationDate,
    });
  }

  _removePendingKnockActivityFeed(String uid1, String uid2) {
    DocumentReference ref =
    activityRef.document(uid1).collection('feedItems').document(uid2);
    ref.get().then((snapshot) {
      if (snapshot.exists) {
        final type = snapshot.data['type'];
        if (type == 'pendingKnock') {
          snapshot.reference.delete();
        }
      }
    });
  }

  _removePendingKnock(String uid1, String uid2) {
    knocksRef
        .document(uid1)
        .collection('receivedKnockFrom')
        .document(uid2)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete().whenComplete(() {
          _removePendingKnockActivityFeed(uid2, uid1);
          _removeSentKnockTo(uid2, uid1);
        });
      }
    });
  }

  _pendingKnocksActionSheet({BuildContext context, String uid}) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Cancel Knock',
        iconData: FontAwesomeIcons.ban,
        color: kColorRed,
        onTap: () {
          _removePendingKnock(uid, currentUserUid);
          Navigator.pop(context);
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Visit Profile',
        iconData: FontAwesomeIcons.doorOpen,
        onTap: () {
          Navigator.pop(context);
          User user = User(uid: uid);
          UserResult result = UserResult(user: user, locationLabel: 'Around');
          result.toProfile(context);
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
                  linkId, currentUserUid, 'socialMedias', 'socials');
              kHandleRemoveDataAtId(linkId, currentUserUid, 'update', 'posts');
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

  _liveChatsActionSheet(
      BuildContext context,
      String title,
      String chatId,
      String hostDisplayName,
      int hostRed,
      int hostGreen,
      int hostBlue,
      String chatHostUid,
      String duration) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    _isCurrentUser
        ? sheets.add(ReusableBottomActionSheetListTile(
      title: 'Delete $title',
      iconData: FontAwesomeIcons.minusCircle,
      color: kColorRed,
      onTap: () {
        kShowAlert(
          context: context,
          title: "Delete Live Chat?",
          desc: "Are you sure you want to delete $title?",
          buttonText: "Delete",
          onPressed: () {
            Navigator.pop(context);
            kHandleRemoveAllLiveChatData(chatId, currentUserUid);
            Navigator.pop(context);
          },
          color: kColorRed,
        );
      },
    ))
        : SizedBox();
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Enter Live Chat',
        iconData: FontAwesomeIcons.externalLinkAlt,
        onTap: () async {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => currentUser.displayName != null
                      ? LiveChatScreen(
                    chatId: chatId,
                  )
                      : CreateDisplayName()));
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

  _changeUserPhoto(bool isChangingProfileImage) {
    if (_isCurrentUser) {
      List<ReusableBottomActionSheetListTile> sheets = [];
      if (!isChangingProfileImage && backgroundImageUrl != null) {
        sheets.add(
            ReusableBottomActionSheetListTile(
              title: 'Remove Background',
              iconData: FontAwesomeIcons.trash,
              onTap: () {
                _removeBackgroundImage();
                Navigator.pop(context);
              },
              color: kColorRed,
            )
        );
      }
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Photo Library',
          iconData: FontAwesomeIcons.images,
          onTap: () async {
            _openPhotoLibrary(isChangingProfileImage);
            Navigator.pop(context);
          },
        ),
      );
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Camera',
          iconData: FontAwesomeIcons.cameraRetro,
          onTap: () async {
            _openCamera(isChangingProfileImage);
            Navigator.pop(context);
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
  }

  _removeBackgroundImage() {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    usersRef.document(currentUserUid).updateData({
      'backgroundImageUrl': FieldValue.delete(),
    }).whenComplete(() {
      _storage.ref().child('profile_background_image/$currentUserUid').delete();
      setState(() {
        backgroundImageUrl = null;
      });
    });
  }

  _openVideoLibrary() async {
    await ImagePicker.pickVideo(source: ImageSource.gallery).then(
          (video) {
        if(video != null)  _uploadFavVideoToFirebase(video);
      },
    );
  }

  Future _uploadFavVideoToFirebase(File videoFile) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });

    StorageUploadTask uploadFile =
    _storage.ref().child('profile_video/$currentUserUid').putFile(videoFile, StorageMetadata(contentType: 'video/mp4'));

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_video')
            .child(currentUserUid)
            .getDownloadURL();

        _saveBackgroundSharedPref(downloadUrl);

        Map<String, String> data = <String, String>{
          'videoUrl': downloadUrl
        };

        usersRef.document(currentUserUid).updateData(data).whenComplete(() {
          if (this.mounted)
            setState(() {
              videoUrl = downloadUrl;
              showSpinner = false;
            });
          initializeFavVid();
        }).catchError(
              (e) => kShowAlert(
            context: context,
            title: 'Upload Failed',
            desc: 'Unable to upload your video, please try again later',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          ),
        );
      }
    });
  }

  _openPhotoLibrary(bool isChangingProfileImage) async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100).then(
          (profilePic) {
        _cropImage(profilePic, isChangingProfileImage);
      },
    );
  }

  _openCamera(bool isChangingProfileImage) async {
    await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 100).then(
          (profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic, isChangingProfileImage);
        }
      },
    );
  }

  _cropImage(File imageFile, bool isChangingProfileImage) async {
    mediaFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
      cropStyle: isChangingProfileImage ? CropStyle.circle : CropStyle.rectangle,
    );
    print(mediaFile);
    if (mediaFile == null) {
      print('did nothing');
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
    } else {
      isChangingProfileImage ? _uploadProfileImageToFirebase(mediaFile) : _uploadBackgroundImageToFirebase(mediaFile);
    }
  }

  Future _uploadProfileImageToFirebase(File profileImage) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    StorageUploadTask uploadFile =
    _storage.ref().child('profile_images_flutter/$currentUserUid').putFile(profileImage);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_images_flutter')
            .child(currentUserUid)
            .getDownloadURL();

        _saveProfileImageSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          'profileImageUrl': '$downloadUrl'
        };
        final ref = usersRef.document(currentUserUid);
        ref.updateData(photoUrl).whenComplete(() {
          print('User updated Photo');
          if (this.mounted)
            setState(() {
              profileImageUrl = downloadUrl;
              showSpinner = false;
            });
        }).catchError(
              (e) => kShowAlert(
            context: context,
            title: 'Upload Failed',
            desc: 'Unable to upload your profile image, please try again later',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          ),
        );
      }
    });
  }

  _saveProfileImageSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', downloadUrl);
  }

  Future _uploadBackgroundImageToFirebase(File backgroundImage) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    if (this.mounted)
      setState(() {
        showSpinner = true;
      });

    StorageUploadTask uploadFile =
    _storage.ref().child('profile_background_image/$currentUserUid').putFile(backgroundImage);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_background_image')
            .child(currentUserUid)
            .getDownloadURL();

        _saveBackgroundSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          'backgroundImageUrl': '$downloadUrl'
        };

        usersRef.document(currentUserUid).updateData(photoUrl).whenComplete(() {
          print('Background Image Added');
          if (this.mounted)
            setState(() {
              backgroundImageUrl = downloadUrl;
              showSpinner = false;
            });
        }).catchError(
              (e) => kShowAlert(
            context: context,
            title: 'Upload Failed',
            desc: 'Unable to upload your background image, please try again later',
            buttonText: 'Try Again',
            onPressed: () => Navigator.pop(context),
            color: kColorRed,
          ),
        );
      }
    });
  }

  _saveBackgroundSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('backgroundImageUrl', downloadUrl);
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
    bool canReport = userUid != null;
    canReport
        ? reportedUsersRef.document(userUid).setData({
      'uid': userUid,
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
          kConfirmBlock(context, username, userUid);
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

  _quickSettings() {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.cog,
        title: 'View Settings',
        color: kColorRed,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => new ListPage()),
          );
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.link,
        title: 'Link Account',
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
        iconData: FontAwesomeIcons.comments,
        title: 'Create Live Chat',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => currentUser.displayName != null
                      ? AddLiveChat()
                      : CreateDisplayName()));
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

  _determinePage() async {
    if (currentUserUid == user.uid) {
      if (this.mounted)
        setState(() {
          _isCurrentUser = true;
        });
      _getCurrentUserData();
    }
//    else if (user.username != null) {
//      _getOtherUserData();
//    }
    else {
      _getUserPageInfo();
    }
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
        .document(currentUserUid)
        .get();
    setState(() {
      _isFollowing = doc.exists;
    });
  }

  _getUserPageInfo() async {
    await usersRef.document(user.uid).get().then((doc) {
      User user = User.fromDocument(doc);
      if (this.mounted)
        setState(() {
          _isCurrentUser = false;
          userUid = user.uid;
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

          displayedWeeklyCount =
              NumberFormat.compact().format(weeklyVisitsCount);
          displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
        });
      usersRef.document(userUid).updateData({
        'weeklyVisitsCount': user.weeklyVisitsCount + 1,
        'totalVisitsCount': user.totalVisitsCount + 1,
      });
    });
    if(videoUrl != null) initializeFavVid();
    _recentProfileVisitUpdate();
  }

  _getOtherUserData() {
    if (this.mounted)
      setState(() {
        _isCurrentUser = false;
        userUid = user.uid;
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

        displayedWeeklyCount = NumberFormat.compact().format(weeklyVisitsCount);
        displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
      });
    usersRef.document(userUid).updateData({
      'weeklyVisitsCount': user.weeklyVisitsCount + 1,
      'totalVisitsCount': user.totalVisitsCount + 1,
    });
    _recentProfileVisitUpdate();
  }

  _recentProfileVisitUpdate() {
    if (!_isCurrentUser && userUid != null) {
      activityRef
          .document(currentUserUid)
          .collection('feedItems')
          .document(currentUserUid)
          .setData({
        'type': 'recentProfileVisit',
        'uid': userUid,
        'username': username,
        'city': locationLabel,
        'profileImageUrl': profileImageUrl,
        'creationDate': DateTime.now().millisecondsSinceEpoch,
        'backgroundImageUrl': backgroundImageUrl,
        'videoUrl': videoUrl,
      });
    }
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
      });
    if(videoUrl != null || videoUrl != '') initializeFavVid();
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

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if(_controller != null) _controller.pause();
  }

//  @override
//  void dispose() {
//    super.dispose();
//    _controller.dispose();
//  }
}

class TopProfileHeaderContainer extends StatelessWidget {
  const TopProfileHeaderContainer({
    @required this.text,
    @required this.fontSize,
    @required this.padding,
  });

  final String text;
  final double fontSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: padding, right: padding),
      decoration: BoxDecoration(
        border: Border.all(color: kColorExtraLightGray),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: kAppBarTextStyle.copyWith(fontSize: fontSize),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }
}

class ReusableContentContainer extends StatelessWidget {
  ReusableContentContainer({@required this.content});

  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(children: content),
    );
  }
}

class FlexibleProfileAppBar extends StatelessWidget {
  final String userPhotoUrl;
  final Function onTap;
  final double topProfileContainerHeight;
  final String weeklyVisitsCount;
  final String totalVisitsCount;
  final String locationLabel;
  final String displayName;
  final int red;
  final int green;
  final int blue;
  final bool isCurrentUser;
  final bool isFollowing;
  final String followersCount;
  final Function followUser;
  final Function unfollowUser;

  const FlexibleProfileAppBar({
    @required this.userPhotoUrl,
    this.onTap,
    this.topProfileContainerHeight,
    this.weeklyVisitsCount,
    this.totalVisitsCount,
    this.locationLabel,
    this.displayName,
    this.red,
    this.green,
    this.blue,
    this.isCurrentUser,
    this.isFollowing,
    this.followersCount,
    this.followUser,
    this.unfollowUser,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ReusableProfileCard(
              imageUrl: userPhotoUrl,
              cardSize: topProfileContainerHeight,
              onTap: onTap,
            ),
            !isCurrentUser
                ? FlatButton(
                    child: !isFollowing
                        ? Text(
                            'Follow',
                            style: kAppBarTextStyle.copyWith(
                                fontSize: 16.0, color: Colors.white),
                          )
                        : Text(
                            'Unfollow',
                            style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          ),
                    color: !isFollowing ? kColorBlue : Colors.transparent,
                    onPressed: !isFollowing ? followUser : unfollowUser,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                          color: !isFollowing
                              ? Colors.transparent
                              : kColorBlack62),
                    ),
                    splashColor: !isFollowing ? kColorDarkBlue : kColorRed,
                    highlightColor: Colors.transparent,
                  )
                : SizedBox(),
            displayName != null
                ? GestureDetector(
                    onTap: () => isCurrentUser
                        ? goToCreateDisplayName(context)
                        : print('do nothing'),
                    child: Text(
                      displayName ?? '',
                      style: kAppBarTextStyle.copyWith(
                        color: Color.fromRGBO(
                          red ?? 95,
                          green ?? 71,
                          blue ?? 188,
                          1.0,
                        ),
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                      ),
                    ),
                  )
                : SizedBox(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Followers: ',
                    style: kAppBarTextStyle.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: followersCount,
                    style: kDefaultTextStyle,
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total Visits: ',
                        style: kAppBarTextStyle.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: totalVisitsCount,
                        style: kDefaultTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'This Week: ',
                        style: kAppBarTextStyle.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: weeklyVisitsCount,
                        style: kDefaultTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.mapMarkerAlt,
                  color: kColorDarkThistle,
                  size: 16.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  locationLabel,
                  style: kAppBarTextStyle.copyWith(color: kColorThistle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  goToCreateDisplayName(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateDisplayName()));
  }
}