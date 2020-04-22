import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/utils/reusable_bottom_sheet.dart';
import 'package:hereme_flutter/widgets/user_result.dart';

class BlockedProfiles extends StatefulWidget {
  @override
  _BlockedProfilesState createState() => _BlockedProfilesState();
}

class _BlockedProfilesState extends State<BlockedProfiles> {
  String name;
  List<User> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  fetchBlockedUsers() {
    if (currentUser.blockedUserUids != null) {
      List<User> listUser = [];
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
            listUser.add(displayUser);
            setState(() {
              listUser.forEach((i) {
                if (!blockedUsers.contains(i)) {
                  this.blockedUsers.add(i);
                }
              });
            });
          });
        }
      });
    }
  }

  buildBlockedList() {
    List<GridTile> gridTiles = [];
    blockedUsers.forEach((user) {
      gridTiles.add(GridTile(
          child: BlockedUserResult(
        user: user,
        onTap: () => _blockedActionSheet(user.uid),
      )));
    });
    if (blockedUsers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(left: 1.0, right: 1.0),
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            shrinkWrap: true,
            children: gridTiles,
          ),
        ],
      );
    } else {
      return Container(
        height: 150.0,
        child: Center(
          child: Text(
            'No Blocked Profiles',
            style: kAppBarTextStyle,
          ),
        ),
      );
    }
  }

  _blockedActionSheet(String uid) {
    List<ReusableBottomActionSheetListTile> sheets = [];
    sheets.add(
      ReusableBottomActionSheetListTile(
        title: 'Unblock',
        iconData: FontAwesomeIcons.ban,
        color: kColorBlue,
        onTap: () async {
          unblockUser(uid);
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

  unblockUser(String uid) {
    usersRef.document(currentUser.uid).updateData(
        {'blockedUsers.$uid': FieldValue.delete()}).whenComplete(() {
          usersRef.document(uid).updateData({'blockedUsers.${currentUser.uid}': FieldValue.delete()});
          kShowAlert(
            context: context,
            title: 'Successfully Unblocked',
            desc: 'You will now be able to see each others content',
            buttonText: 'Dismiss',
            onPressed: Navigator.pop(context),
            color: kColorBlue,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Blocked Profiles",
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack62,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: buildBlockedList(),
      ),
    );
  }
}
