import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/SettingsMenu/SocialMediasList.dart';
import 'package:hereme_flutter/SettingsMenu/recents/add_recents.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/live_chat/add_live_chat.dart';
import 'package:hereme_flutter/models/knock.dart';
import 'package:hereme_flutter/models/linked_account.dart';
import 'package:hereme_flutter/models/recent_upload.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/registration/create_display_name.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:hereme_flutter/SettingsMenu/MenuListPage.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _firestore = Firestore.instance;
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
  String knockUsername = '';
  String knockUrl = '';
  String knockUid = '';

  bool showSpinner = false;
  bool _isCurrentUser = false;
  String username;
  String displayName;
  String userUid;
  String profileImageUrl;
  int weeklyVisitsCount;
  String displayedWeeklyCount;
  int totalVisitsCount;
  String displayedTotalCount;
  final String currentUserUid = currentUser?.uid;

  final User user;
  final String locationLabel;
  _ProfileState({this.user, this.locationLabel});

  @override
  void initState() {
    super.initState();
    _determinePage();
    if (_isCurrentUser) {
      updateCurrentUserCounts();
    }
  }

  getKnockInfo(String uid) {
    usersRef.document(uid).snapshots().listen((snaps) {
      setState(() {
        knockUsername = snaps.data['username'];
        knockUrl = snaps.data['profileImageUrl'];
        print(knockUrl);
      });
    });
  }

  updateCurrentUserCounts() async {
    if (_isCurrentUser) {
      usersRef.document(currentUserUid).snapshots().listen((doc) {
        setState(() {
          weeklyVisitsCount = doc.data['weeklyVisitsCount'];
          totalVisitsCount = doc.data['totalVisitsCount'];

          displayedWeeklyCount =
              NumberFormat.compact().format(weeklyVisitsCount);
          displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
        });
      });
    }
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double topProfileContainerHeight = screenHeight / 4 + 16;

    return Scaffold(
      backgroundColor: kColorOffWhite,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: circularProgress(),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  child: SliverSafeArea(
                    sliver: SliverAppBar(
                      backgroundColor: kColorOffWhite,
                      floating: false,
                      pinned: true,
                      snap: false,
                      leading: IconButton(
                        icon: Icon(FontAwesomeIcons.chevronLeft),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: kColorBlack71,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey[200],
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.ellipsisV,
                              color: kColorBlack71),
                          onPressed: () {
                            _isCurrentUser ? _quickSettings() : _reportBlockSettings();
                          },
                        )
                      ],
                      elevation: 2.0,
                      expandedHeight: topProfileContainerHeight + 50.0,
                      title: Text(
                        username != null ? username : '',
                        style: kAppBarTextStyle,
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: FlexibleProfileAppBar(
                          userPhotoUrl: profileImageUrl,
                          onTap: _isCurrentUser
                              ? _changeUserPhoto
                              : _fullScreenProfileImage,
                          topProfileContainerHeight: topProfileContainerHeight,
                          weeklyVisitsCount: displayedWeeklyCount,
                          totalVisitsCount: displayedTotalCount,
                          locationLabel: _isCurrentUser
                              ? 'Here'
                              : locationLabel ?? 'Around',
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SafeArea(
              child: Theme(
                data: kTheme(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ListView.builder(
                    itemCount: _isCurrentUser ? 3 : 3,
                    itemBuilder: (context, index) {
                      if (_isCurrentUser) {
                        if (index == 0) {
                          //Current User Knocks
                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: ReusableSectionLabel(title: 'Knocks'),
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: knocksRef
                                    .document(currentUserUid)
                                    .collection('receivedKnockFrom')
                                    .orderBy('creationDate', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return circularProgress();
                                  }
                                  final knocks = snapshot.data.documents;
                                  List<Knock> displayedKnocks = [];
                                  for (var knock in knocks) {
//                                    final username = knock.data['username'];
//                                    final imageUrl = knock.data['profileImageUrl'];
                                    final creationDate =
                                        knock.data['creationDate'];
                                    final uid = knock.data['uid'];
                                    print(uid);

                                    getKnockInfo(uid);

                                    final displayedKnock = Knock(
                                      username: knockUsername,
                                      imageUrl: knockUrl,
                                      creationDate: creationDate,
                                      onTap: () {
                                        _knocksActionSheet(
                                            context, uid, knockUsername);
                                      },
                                    );
                                    displayedKnocks.add(displayedKnock);
                                  }
                                  if (displayedKnocks.isNotEmpty) {
                                    return ReusableContentContainer(
                                      content: displayedKnocks,
                                    );
                                  } else {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: 2.0, bottom: 8.0),
                                      child: Text(
                                        'No Knocks Yet',
                                        style: kDefaultTextStyle,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        } else if (index == 1) {
                          //Current User Links
                          return ExpansionTile(
                            initiallyExpanded: false,
                            title: ReusableSectionLabel(title: 'Links'),
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: socialMediasRef
                                    .document(currentUserUid)
                                    .collection('socials')
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

                                          _determineUrl(
                                              accountUsername, iconString, url);

                                          final displayedAccount =
                                              LinkedAccount(
                                            accountUsername: accountUsername,
                                            accountUrl: url,
                                            iconString: iconString,
                                            onTap: () {
                                              _linksActionSheet(
                                                context,
                                                accountUsername,
                                                iconString,
                                                url,
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
                                    _updateFirestoreHasAccountLinked();
                                    return ReusableBottomActionSheetListTile(
                                      iconData: FontAwesomeIcons.link,
                                      title: 'Link Account',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  MediasList()),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
//                        ReusableSectionLabel(title: 'Recents'),
                            ],
                          );
                        } else {
                          //Current User Recents
                          return ExpansionTile(
                            title: ReusableSectionLabel(title: 'Recents'),
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: recentUploadsRef
                                    .document(currentUserUid)
                                    .collection('recents')
                                    .orderBy('creationDate', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return circularProgress();
                                  }
                                  final recents = snapshot.data.documents;
                                  List<RecentUpload> displayedRecents = [];
                                  for (var recent in recents) {
                                    final imageUrl =
                                        recent.data['thumbnailImageUrl'];
                                    final title = recent.data['title'];
                                    final url = recent.data['url'];
                                    final creationDate =
                                        recent.data['creationDate'];
                                    final storageFilename =
                                        recent.data['storageFilename'];

                                    _determineUrl(title, '', url);

                                    final displayedRecent = RecentUpload(
                                      title: title,
                                      url: url,
                                      imageUrl: imageUrl,
                                      creationDate: creationDate,
                                      onTap: () {
                                        _recentsActionSheet(context, title, url,
                                            storageFilename);
                                      },
                                    );
                                    displayedRecents.add(displayedRecent);
                                  }
                                  if (displayedRecents.isNotEmpty) {
                                    return ReusableContentContainer(
                                      content: displayedRecents,
                                    );
                                  } else {
                                    return _isCurrentUser
                                        ? ReusableBottomActionSheetListTile(
                                            iconData: FontAwesomeIcons.upload,
                                            title: 'Add Recent',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        AddRecent()),
                                              );
                                            },
                                          )
                                        : Text('No Recent Uploads',
                                            style: kDefaultTextStyle);
                                  }
                                },
                              ),
                            ],
                          );
                        }
                      } else {
                        if (index == 0) {
                          //User Links
                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: ReusableSectionLabel(title: 'Links'),
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: socialMediasRef
                                    .document(userUid)
                                    .collection('socials')
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

                                          _determineUrl(
                                              accountUsername, iconString, url);

                                          final displayedAccount =
                                              LinkedAccount(
                                            accountUsername: accountUsername,
                                            accountUrl: url,
                                            iconString: iconString,
                                            onTap: () {
                                              _linksActionSheet(
                                                  context,
                                                  accountUsername,
                                                  iconString,
                                                  url);
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
                          );
                        } else if (index == 1) {
                          //User Recents
                          return ExpansionTile(
                            title: ReusableSectionLabel(title: 'Recents'),
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: recentUploadsRef
                                    .document(userUid)
                                    .collection('recents')
                                    .orderBy('creationDate', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return circularProgress();
                                  }
                                  final recents = snapshot.data.documents;
                                  List<RecentUpload> displayedRecents = [];
                                  for (var recent in recents) {
                                    final imageUrl =
                                        recent.data['thumbnailImageUrl'];
                                    final title = recent.data['title'];
                                    final url = recent.data['url'];
                                    final creationDate =
                                        recent.data['creationDate'];
                                    final storageFilename =
                                        recent.data['storageFilename'];

                                    _determineUrl(title, '', url);

                                    final displayedRecent = RecentUpload(
                                      title: title,
                                      url: url,
                                      imageUrl: imageUrl,
                                      creationDate: creationDate,
                                      onTap: () {
                                        _recentsActionSheet(context, title, url,
                                            storageFilename);
                                      },
                                    );
                                    displayedRecents.add(displayedRecent);
                                  }
                                  if (displayedRecents.isNotEmpty) {
                                    return ReusableContentContainer(
                                      content: displayedRecents,
                                    );
                                  } else {
                                    return _isCurrentUser
                                        ? ReusableBottomActionSheetListTile(
                                            iconData: FontAwesomeIcons.upload,
                                            title: 'Add Recent',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        AddRecent()),
                                              );
                                            },
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                top: 2.0, bottom: 8.0),
                                            child: Text(
                                              'No Recent Uploads',
                                              style: kDefaultTextStyle,
                                            ),
                                          );
                                  }
                                },
                              ),
                            ],
                          );
                        } else {
                          //User Knock
                          return ExpansionTile(
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 24,
                            ),
                            title: ReusableSectionLabel(title: 'Knock'),
                            onExpansionChanged: (expanded) {
                              kShowAlertMultiButtons(
                                  context: context,
                                  title: 'Knock Knock',
                                  desc: 'Did you mean to Knock $username?',
                                  buttonText1: 'Yes',
                                  color1: kColorGreen,
                                  buttonText2: 'Cancel',
                                  color2: kColorLightGray,
                                  onPressed1: () {
                                    _handleKnock(userUid);
                                    Navigator.pop(context);
                                  },
                                  onPressed2: () {
                                    Navigator.pop(context);
                                  });
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _fullScreenProfileImage() {
    print('full screen');
  }

  _updateFirestoreHasAccountLinked() {
    usersRef.document(currentUserUid).updateData({
      'hasAccountLinked': false,
    });
  }

  _handleKnock(String uid) async {
    final ref = knocksRef
        .document(uid)
        .collection('receivedKnockFrom')
        .document(currentUserUid);
    final newRef = ref.get();
    newRef.then((doc) {
      if (!doc.exists) {
        _sendKnock(ref);
      } else {
        kShowFlushBar(
            text: 'Already Knocked $username',
            context: context,
            icon: FontAwesomeIcons.times,
            color: kColorRed);
      }
    });
  }

  _sendKnock(DocumentReference ref) {
    Map<String, dynamic> knockData = <String, dynamic>{
      'uid': currentUserUid,
      'profileImageUrl': currentUser?.profileImageUrl ?? '',
      'username': currentUser?.username ?? '',
      'creationDate': DateTime.now().millisecondsSinceEpoch * 1000,
    };
    ref.setData(knockData).whenComplete(() {
      kShowFlushBar(
          text: 'Successfully sent Knock',
          context: context,
          icon: FontAwesomeIcons.paperPlane,
          color: kColorGreen);
    }).catchError(
      (e) => kShowAlert(
        context: context,
        title: 'Knock Failed',
        desc: 'Unable to knock $username, please try again later',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  _knocksActionSheet(BuildContext context, String uid, String username) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Deny Knock',
        iconData: FontAwesomeIcons.ban,
        color: kColorRed,
        onTap: () async {
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
          _handleKnock(uid);
          _removeKnock(uid);
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

  _linksActionSheet(BuildContext context, String accountUsername,
      String iconString, String url) {
    String platform;
    for (var platformString
    in _determineUrl(accountUsername, iconString, url).keys) {
      platform = platformString;
    }
    List<ReusableBottomActionSheetListTile> sheets = [];
    _isCurrentUser
        ? sheets.add(ReusableBottomActionSheetListTile(
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
            _handleRemoveData(accountUsername, 'socialMedias', 'socials');
            Navigator.pop(context);
          },
        );
      },
    )) : SizedBox();
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
          kShowFlushBar(
              text: "Copied $accountUsername",
              icon: FontAwesomeIcons.clipboardCheck,
              color: kColorGreen,
              context: context);
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

  _recentsActionSheet(
      BuildContext context, String title, String url, String storageFilename) {
    String platform;
    for (var platformString in _determineUrl(title, '', url).keys) {
      platform = platformString;
    }
    List<ReusableBottomActionSheetListTile> sheets = [];
    _isCurrentUser
        ? sheets.add(ReusableBottomActionSheetListTile(
      title: 'Remove $title',
      iconData: FontAwesomeIcons.minusCircle,
      color: kColorRed,
      onTap: () {
        kShowAlert(
          context: context,
          title: "Remove Recent?",
          desc: "Are you sure you want to remove $title?",
          buttonText: "Delete",
          onPressed: () {
            Navigator.pop(context);
            _handleRemoveData(title, 'recentUploads', 'recents');
            _handleRemoveRecentThumbnailFromStorage(storageFilename);
            Navigator.pop(context);
          },
        );
      },
    )) : SizedBox();
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Open in $platform',
        iconData: FontAwesomeIcons.externalLinkAlt,
        onTap: () async {
          _launchUrl(title, '', url);
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

  _handleRemoveRecentThumbnailFromStorage(String storageFilename) {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      _storage
          .ref()
          .child('recent_upload_thumbnail')
          .child(currentUserUid)
          .child(storageFilename)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  _handleRemoveData(String key, String collection1, String collection2) async {
    final ref = _firestore
        .collection(collection1)
        .document(currentUserUid)
        .collection(collection2);

    ref.getDocuments().then((snapshot) {
      for (final doc in snapshot.documents) {
        if (doc.data.containsValue(key)) {
          ref.document(doc.documentID).delete();
        }
      }
    });
  }

  _changeUserPhoto() {
    if (_isCurrentUser) {
      List<ReusableBottomActionSheetListTile> sheets = [];
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Photo Library',
          iconData: FontAwesomeIcons.images,
          onTap: () async {
            _openPhotoLibrary();
            Navigator.pop(context);
          },
        ),
      );
      sheets.add(
        ReusableBottomActionSheetListTile(
          title: 'Camera',
          iconData: FontAwesomeIcons.cameraRetro,
          onTap: () async {
            _openCamera();
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
    canReport ? reportedUsersRef.document(userUid).setData({
      'uid': userUid,
      'username': username,
      'displayName': displayName,
      'reason': reason,
      'reportedByUid': currentUser.uid,
    }).whenComplete(() {
      kShowFlushBar(context: context, text: 'Successfully Reported', color: kColorGreen, icon: FontAwesomeIcons.exclamation);
    }) : kErrorFlushbar(context: context, errorText: 'Unable to Report, please try again');
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
        color: kColorPurple,
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
            MaterialPageRoute(builder: (BuildContext context) => MediasList()),
          );
        },
      ),
    );
    sheets.add(
      ReusableBottomActionSheetListTile(
        iconData: FontAwesomeIcons.upload,
        title: 'Add Recent Upload',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => AddRecent()),
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

  _openPhotoLibrary() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then(
      (profilePic) {
        _cropImage(profilePic);
        setState(() {
          showSpinner = false;
        });
      },
    );
  }

  _openCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then(
      (profilePic) {
        if (profilePic != null) {
          _cropImage(profilePic);
          setState(() {
            showSpinner = false;
          });
        } else {
          setState(() {
            showSpinner = false;
          });
        }
      },
    );
  }

  _determinePage() async {
    if (currentUserUid == user.uid) {
      setState(() {
        _isCurrentUser = true;
      });
      _getCurrentUserData();
    } else if (user.username != null) {
      setState(() {
        _isCurrentUser = false;
        userUid = user.uid;
        username = user.username;
        displayName = user.displayName;
        profileImageUrl = user.profileImageUrl;
        weeklyVisitsCount = user.weeklyVisitsCount + 1;
        totalVisitsCount = user.totalVisitsCount + 1;

        displayedWeeklyCount = NumberFormat.compact().format(weeklyVisitsCount);
        displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
      });
      usersRef.document(userUid).updateData({
        'weeklyVisitsCount': user.weeklyVisitsCount + 1,
        'totalVisitsCount': user.totalVisitsCount + 1,
      });
    } else {
      getUserPageInfo();
    }
  }

  getUserPageInfo() async {
    await usersRef.document(widget.user.uid).get().then((doc) {
      User user = User.fromDocument(doc);
      setState(() {
        _isCurrentUser = false;
        userUid = user.uid;
        username = user.username;
        displayName = user.displayName;
        profileImageUrl = user.profileImageUrl;
        weeklyVisitsCount = user.weeklyVisitsCount + 1;
        totalVisitsCount = user.totalVisitsCount + 1;

        displayedWeeklyCount = NumberFormat.compact().format(weeklyVisitsCount);
        displayedTotalCount = NumberFormat.compact().format(totalVisitsCount);
      });
      usersRef.document(userUid).updateData({
        'weeklyVisitsCount': user.weeklyVisitsCount + 1,
        'totalVisitsCount': user.totalVisitsCount + 1,
      });
    });
  }

  _getCurrentUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('profileImageUrl');
    String name = prefs.getString('username');
    setState(() {
      profileImageUrl = url;
      username = name;
      displayName = currentUser.displayName;
    });
  }

  _savePhotoSharedPref(String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', downloadUrl);
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1.0,
        ratioY: 1.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    );
    _uploadImageToFirebase(croppedFile);
  }

  Future _uploadImageToFirebase(File profilePic) async {
    final userReference = _firestore.collection('users');
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var succeed = true;

    setState(() {
      showSpinner = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    StorageUploadTask uploadFile =
        _storage.ref().child('profile_images/$uid').putFile(profilePic);

    uploadFile.onComplete.catchError((error) {
      print(error);
      succeed = false;
    }).then((uploaded) async {
      if (succeed == true) {
        final downloadUrl = await _storage
            .ref()
            .child('profile_images')
            .child(uid)
            .getDownloadURL();

        _savePhotoSharedPref(downloadUrl);

        Map<String, String> photoUrl = <String, String>{
          'profileImageUrl': '$downloadUrl'
        };

        userReference.document(uid).updateData(photoUrl).whenComplete(() {
          print('User Photo Added');
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
          ),
        );
      }
    });
  }

  _launchUrl(String accountUsername, String iconString, String url) async {
    for (var urlString
        in _determineUrl(accountUsername, iconString, url).values) {
      url = urlString;
    }

    print(url);

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      kShowFlushBar(
        text: 'Whoops, unable to open in app',
        icon: FontAwesomeIcons.exclamation,
        color: kColorRed,
        context: context,
      );
    }
  }

  Map<String, String> _determineUrl(
      String accountUsername, String iconString, String url) {
    final icon = iconString;
    //TODO: firebase pull url if key contains URL and put that value in socialMedUrl
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
    } else {
      retMap = {'Browser': url};
    }
    return retMap;
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
        borderRadius: BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100],
            blurRadius: 3.0,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Column(children: content),
    );
  }
}

class ReusableSectionLabel extends StatelessWidget {
  ReusableSectionLabel({@required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(title, style: kAppBarTextStyle),
    );
  }
}

class FlexibleProfileAppBar extends StatelessWidget {
  final double appBarHeight = 66.0;

  final String userPhotoUrl;
  final Function onTap;
  final double topProfileContainerHeight;
  final String weeklyVisitsCount;
  final String totalVisitsCount;
  final String locationLabel;

  const FlexibleProfileAppBar(
      {@required this.userPhotoUrl,
      this.onTap,
      this.topProfileContainerHeight,
      this.weeklyVisitsCount,
      this.totalVisitsCount,
      this.locationLabel});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + appBarHeight,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: topProfileContainerHeight,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ReusableProfileCard(
                      imageUrl: userPhotoUrl,
                      cardSize: topProfileContainerHeight,
                      onTap: onTap,
                    ),
                    Text('Visits this week: $weeklyVisitsCount',
                        style: kAppBarTextStyle.copyWith(
                            fontSize: 14.0, fontWeight: FontWeight.normal)),
                    Text('Total Visits: $totalVisitsCount',
                        style: kAppBarTextStyle.copyWith(
                            fontSize: 14.0, fontWeight: FontWeight.normal)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.mapMarkerAlt,
                          color: kColorDarkThistle,
                          size: 14.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          locationLabel,
                          style:
                              kAppBarTextStyle.copyWith(color: kColorThistle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )),
      decoration: BoxDecoration(
        color: kColorOffWhite,
      ),
    );
  }
}
