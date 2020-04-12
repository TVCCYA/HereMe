import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants.dart';
import 'bottom_bar.dart';

class ViewAllLatestText extends StatefulWidget {
  final List<String> blockedUids;
  final Stream<QuerySnapshot> query;
  ViewAllLatestText({this.blockedUids, this.query});
  @override
  _ViewAllLatestTextState createState() => _ViewAllLatestTextState(
    blockedUids: this.blockedUids,
    query: this.query
  );
}

class _ViewAllLatestTextState extends State<ViewAllLatestText> {
  final List<String> blockedUids;
  final Stream<QuerySnapshot> query;
  _ViewAllLatestTextState({this.blockedUids, this.query});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  buildLatestPosts() {
    return StreamBuilder(
      stream: query,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final updates = snapshot.data.documents;
        List<LatestPost> displayedUpdates = [];
        for (var post in updates) {
          final String title = post.data['title'];
          final int creationDate = post.data['creationDate'];
          final String type = post.data['type'];
          final String id = post.data['id'];
          final dynamic likes = post.data['likes'];
          final String uid = post.data['uid'];
          final String displayName = post.data['displayName'];
          final String profileImageUrl = post.data['profileImageUrl'];

          final displayedPost = LatestPost(
            photoUrl: '',
            title: title,
            creationDate: creationDate,
            type: type,
            uid: uid,
            id: id,
            displayName: displayName ?? '?',
            likes: likes ?? {},
            profileImageUrl: profileImageUrl,
          );
          if (!blockedUids.contains(uid) && type == 'text') {
            displayedUpdates.add(displayedPost);
          }
        }
        if (displayedUpdates.isNotEmpty) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayedUpdates);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: kColorOffWhite,
        elevation: 2.0,
        title: Text('Latest Texts', style: kAppBarTextStyle),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          waterDropColor: kColorExtraLightGray,
          idleIcon: Icon(
            FontAwesomeIcons.solidCommentDots,
            color: kColorRed,
            size: 18.0,
          ),
          complete: Icon(
            FontAwesomeIcons.arrowDown,
            color: kColorLightGray,
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
            child: buildLatestPosts()
        ),
      ),
    );
  }

  _onRefresh() {
    kSelectionClick();
    _refreshController.refreshCompleted();
  }
}
