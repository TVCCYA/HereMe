import 'package:flutter/material.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/profile_page/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  toProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(user: user),
      ),
    );
//    incrementViewCount();
  }

  incrementViewCount() {
    if (currentUser.uid != user.uid) {
      usersRef.document(user.uid).updateData({
        'weeklyVisitsCount': user.weeklyVisitsCount + 1,
        'totalVisitsCount': user.totalVisitsCount + 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toProfile(context),
      child: cachedNetworkImage(user.profileImageUrl),
    );
  }
}
