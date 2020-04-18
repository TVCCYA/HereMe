import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';
import 'package:hereme_flutter/widgets/user_result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReceivedKnocks extends StatefulWidget {
  @override
  _ReceivedKnocksState createState() => _ReceivedKnocksState();
}

class _ReceivedKnocksState extends State<ReceivedKnocks> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  fetchKnocks() {
    return FutureBuilder(
      future: knocksRef
          .document(currentUser.uid)
          .collection('receivedKnockFrom')
          .orderBy('creationDate', descending: true)
          .getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final List<DocumentSnapshot> knocks = snapshot.data.documents;
        final List<ReceivedKnock> displayedKnocks = [];
        for (var knock in knocks) {
          final String uid = knock.documentID;
          final displayedKnock = ReceivedKnock(
            uid: uid,
          );
          displayedKnocks.add(displayedKnock);
        }
        if (displayedKnocks.isNotEmpty) {
          return Column(
            children: displayedKnocks,
          );
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No Knocks Yet', style: kDefaultTextStyle),
          ),
        );
      },
    );
  }

  _onRefresh() {
    kSelectionClick();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          brightness: Brightness.light,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Text(
            'Received Knocks',
            style: kAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: kColorBlack71, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Theme(
          data: kTheme(context),
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                waterDropColor: kColorExtraLightGray,
                idleIcon: Icon(
                  FontAwesomeIcons.doorOpen,
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
              child: isLoading ? circularProgress() : Column(children: <Widget>[fetchKnocks()],),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceivedKnock extends StatefulWidget {
  final String uid;
  ReceivedKnock({this.uid});
  @override
  _ReceivedKnockState createState() => _ReceivedKnockState(
    uid: this.uid
  );
}

class _ReceivedKnockState extends State<ReceivedKnock> {
  final String uid;
  _ReceivedKnockState({this.uid});

  @override
  void initState() {
    super.initState();
    _getUserPageData();
  }

  bool knockedBack = false;
  String username = '';
  String profileImageUrl = '';

  _getUserPageData() {
      usersRef.document(uid).get().then((doc) {
        User user = User.fromDocument(doc);
        if (this.mounted)
          setState(() {
            username = user.username;
            profileImageUrl = user.profileImageUrl;
          });
      });
  }

  buildTile() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: _goToProfile,
              child: Row(
                children: <Widget>[
                  cachedUserResultImage(profileImageUrl, 45, true),
                  SizedBox(width: 12.0),
                  Container(
                    width: screenWidth / 3.25,
                    child: Text(
                      username,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: kAppBarTextStyle.copyWith(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ReusableRoundedCornerButton(
                  width: 10,
                  height: 30,
                  text: knockedBack ? 'Knocked' : 'Knock',
                  onPressed: () => _handleKnock(uid),
                  textColor: kColorLightGray,
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  iconSize: 16,
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(FontAwesomeIcons.times, color: kColorBlack71),
                  onPressed: () => _removeKnock(uid),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _goToProfile() {
    User user = User(uid: uid);
    UserResult result = UserResult(user: user, locationLabel: 'Around');
    result.toProfile(context);
  }

  _handleKnock(String uid) {
    final ref = knocksRef
        .document(uid)
        .collection('receivedKnockFrom')
        .document(currentUser.uid);
    final newRef = ref.get();
    newRef.then((doc) {
      if (!doc.exists && uid != null) {
        _sendKnock(ref);
        if (this.mounted)
          setState(() {
            knockedBack = true;
          });
      }
    });
  }

  _sendKnock(DocumentReference ref) {
    int creationDate = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> knockData = <String, dynamic>{
      'creationDate': creationDate,
    };
    ref.setData(knockData).whenComplete(() {
      _updateSentKnockTo(uid);
    }).catchError((e) => kShowAlert(
        context: context,
        title: 'Knock Failed',
        desc: 'Unable to knock $username, please try again later',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
        color: kColorRed));
  }

  _updateSentKnockTo(String uid) {
    final creationDate = DateTime.now().millisecondsSinceEpoch;
    knocksRef
        .document(currentUser.uid)
        .collection('sentKnockTo')
        .document(uid)
        .setData({
      'creationDate': creationDate,
    }).whenComplete(() {
      _removeSentKnockTo(uid, currentUser.uid);
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

  @override
  Widget build(BuildContext context) {
    return buildTile();
  }
}

