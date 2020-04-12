import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/widgets/update_post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants.dart';
import 'bottom_bar.dart';

class ViewAllLatestPhotos extends StatefulWidget {
  final List<String> blockedUids;
  final Stream<QuerySnapshot> query;

  ViewAllLatestPhotos({this.blockedUids, this.query});

  @override
  _ViewAllLatestPhotosState createState() => _ViewAllLatestPhotosState(
        blockedUids: this.blockedUids,
    query: this.query,
      );
}

class _ViewAllLatestPhotosState extends State<ViewAllLatestPhotos> {
  final List<String> blockedUids;
  final Stream<QuerySnapshot> query;
  _ViewAllLatestPhotosState({this.blockedUids, this.query});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = true;

  buildLatestPosts() {
    return StreamBuilder(
      stream: query,
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
              List<LatestPost> displayedUpdates = [];
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
                  isHome: false,
                );
                if (!blockedUids.contains(uid) && type == 'photo') {
                  displayedUpdates.add(displayedPost);
                }
              }
              if (displayedUpdates.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: StaggeredGridView.countBuilder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    itemCount: displayedUpdates.length,
                    itemBuilder: (BuildContext context, int i) {
                      var post = displayedUpdates[i];
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
                    staggeredTileBuilder: (int index) =>
                        new StaggeredTile.count(2, index.isEven ? 4 : 3),
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
        title: Text('Latest Photos', style: kAppBarTextStyle),
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
            FontAwesomeIcons.solidImages,
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
        child: SingleChildScrollView(child: buildLatestPosts()),
      ),
    );
  }

  _onRefresh() {
    kSelectionClick();
    _refreshController.refreshCompleted();
  }
}
