import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/user_profile/profile_image_full_screen.dart';
import 'package:hereme_flutter/widgets/update_post.dart';

class PostFullScreen extends StatefulWidget {
  final String postId;
  final String uid;
  final String title;
  final String displayName;
  final String username;
  final String photoUrl;
  final int creationDate;
  final String type;
  final String profileImageUrl;
  final dynamic likes;
  PostFullScreen({
    this.postId,
    this.uid,
    this.title,
    this.displayName,
    this.username,
    this.photoUrl,
    this.creationDate,
    this.type,
    this.profileImageUrl,
    this.likes,
  });
  @override
  _PostFullScreenState createState() =>
      _PostFullScreenState(
        postId: this.postId ?? '',
        uid: this.uid ?? '',
        title: this.title ?? '',
        displayName: this.displayName ?? '',
        username: this.username ?? '',
        photoUrl: this.photoUrl ?? '',
        creationDate: this.creationDate ?? 0,
        type: this.type ?? '',
        profileImageUrl: this.profileImageUrl ?? '',
        likes: this.likes ?? {}
      );
}

class _PostFullScreenState extends State<PostFullScreen> {
  final String postId;
  final String uid;
  final String title;
  final String displayName;
  final String username;
  final String photoUrl;
  final int creationDate;
  final String type;
  final String profileImageUrl;
  final dynamic likes;
  _PostFullScreenState({
    this.postId,
    this.uid,
    this.title,
    this.displayName,
    this.username,
    this.photoUrl,
    this.creationDate,
    this.type,
    this.profileImageUrl,
    this.likes,
  });

  LatestPost post = LatestPost();

  @override
  void initState() {
    super.initState();
    post = LatestPost(
      photoUrl: photoUrl,
      uid: uid,
      creationDate: creationDate,
      id: postId,
      displayName: displayName ?? username,
      profileImageUrl: profileImageUrl,
      likes: likes,
      title: title,
      type: type,
      isHome: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: Scaffold(
        backgroundColor: kColorOffWhite,
        appBar: AppBar(
          brightness: Brightness.light,
          elevation: 2.0,
          backgroundColor: kColorOffWhite,
          title: Text(
            'Latest',
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
        body: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: GestureDetector(
            onTap: () {

              photoUrl != '' ? Navigator.push(context, FadeRoute(page: FullScreenLatestPhoto(index: 0, displayedUpdates: [post])))
                  : print('do nothing');
            },
            child: post
          ),
        ),
      ),
    );
  }
}
