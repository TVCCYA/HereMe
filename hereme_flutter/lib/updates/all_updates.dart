import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/widgets/update_post.dart';

import '../constants.dart';

class AllUpdates extends StatefulWidget {
  final String uid;
  final String displayName;

  AllUpdates({this.uid, this.displayName});

  @override
  _AllUpdatesState createState() => _AllUpdatesState(
    uid: this.uid,
    displayName: this.displayName,
  );
}

class _AllUpdatesState extends State<AllUpdates> {
  final String uid;
  final String displayName;

  _AllUpdatesState({this.uid, this.displayName});

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
          'Updates',
          textAlign: TextAlign.left,
          style: kAppBarTextStyle,
        ),
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
      body: SafeArea(
        child: Container(
          height: screenHeight,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(right: 4.0, left: 4.0, top: 8.0, bottom: 8.0),
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
                  List<UpdatePost> displayedUpdates = [];
                  for (var post in updates) {

                    final String photoUrl = post.data['photoUrl'];
                    final String title = post.data['title'];
                    final int creationDate = post.data['creationDate'];
                    final String type = post.data['type'];
                    final String id = post.data['id'];
                    final dynamic likes = post.data['likes'];

                    final displayedPost = UpdatePost(
                      photoUrl: photoUrl,
                      title: title,
                      creationDate: creationDate,
                      type: type,
                      uid: uid,
                      id: id,
                      displayName: displayName,
                      likes: likes ?? {},
                    );
                    displayedUpdates
                        .add(displayedPost);
                  }
                  return Column(children: displayedUpdates);
                },
              ),
            ),
          ),
        )
      ),
    );
  }
}
