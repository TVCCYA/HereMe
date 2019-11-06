import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/widgets/user_result.dart';

class BlockedProfiles extends StatefulWidget {
  @override
  _BlockedProfilesState createState() => _BlockedProfilesState();
}

class _BlockedProfilesState extends State<BlockedProfiles> {
  List<UserResult> blockedUsers = [];
  String name;
  List<User> users = [];

  buildBlockedList() {
    if (currentUser.blockedUserUids != null) {
      currentUser.blockedUserUids.forEach((key, val) {
        if (val == 1) {
          usersRef.document(key).snapshots().forEach((snapshot) {
            final username = snapshot.data['username'];
            final profileImageUrl = snapshot.data['profileImageUrl'];
            final displayUser = User(
              uid: key,
              username: username,
              profileImageUrl: profileImageUrl,
            );
            List<UserResult> listResult = [];
            UserResult result = UserResult(user: displayUser);
            listResult.add(result);
            print(username);
            print(profileImageUrl);
            setState(() {
              name = username;
            });
          });
        }
      });
      return Column(
        children: <Widget>[
          Text(
            name,
          ),
        ],
      );
    }

//    print(blockedUsers.length);
//    return FutureBuilder(
//      future: usersRef.document(currentUser.uid).get(),
//      builder: (context, snapshot) {
//        if (snapshot.data['blockedUsers'] == null) {
//          return SizedBox();
//        }
//        final blockedUsers = snapshot.data['blockedUsers'];
//        return Column();
//      },
//    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Blocked Profiles",
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: buildBlockedList(),
    );
  }
}
