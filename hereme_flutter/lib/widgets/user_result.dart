import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';

class UserResult extends StatelessWidget {
  final User user;
  final String locationLabel;

  UserResult({this.user, this.locationLabel});

  toProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(user: user, locationLabel: locationLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => toProfile(context),
//      child: cachedUserResultImage(user.profileImageUrl, 5, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          cachedUserResultImage(user.profileImageUrl, 80),
          Text(user.username ?? 'name', style: kDefaultTextStyle.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}

class BlockedUserResult extends StatelessWidget {
  final User user;
  final Function onTap;
  BlockedUserResult({this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: cachedUserResultImage(user.profileImageUrl, 40),
    );
  }
}
