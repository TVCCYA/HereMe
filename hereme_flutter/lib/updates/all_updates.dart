import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/widgets/update_post.dart';

import '../constants.dart';

class AllUpdates extends StatefulWidget {
  final String uid;
  final String displayName;
  final int red;
  final int green;
  final int blue;

  AllUpdates({this.uid, this.displayName, this.red, this.green, this.blue});

  @override
  _AllUpdatesState createState() => _AllUpdatesState(
    uid: this.uid,
    displayName: this.displayName,
    red: this.red,
    green: this.green,
    blue: this.blue,
  );
}

class _AllUpdatesState extends State<AllUpdates> {
  final String uid;
  final String displayName;
  String count;
  final int red;
  final int green;
  final int blue;

  _AllUpdatesState({this.uid, this.displayName, this.red, this.green, this.blue});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          count == null ? 'Latest' : '$count Latest',
          textAlign: TextAlign.left,
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: Container(
        height: screenHeight,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: updateRef
                  .document(uid)
                  .collection('posts')
                  .orderBy('creationDate', descending: true)
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
                    uid: uid,
                    id: id,
                    displayName: displayName,
                    likes: likes ?? {},
                    red: red,
                    green: green,
                    blue: blue,
                  );
                  displayedUpdates
                      .add(displayedPost);
                  if (type == 'photo') {
                    displayedPhotos.add(displayedPost);
                  }
                }
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: displayedUpdates.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () =>
                            Navigator.push(
                              context,
                              FadeRoute(
                                page: FullScreenLatestPhoto(index: displayedPhotos.indexOf(displayedUpdates[i]), displayedUpdates: displayedPhotos),
                              ),
                            ),
                        child: displayedUpdates[i],
                      );
                    },
                  );
              },
            ),
          ),
        ),
      ),
    );
  }
}
