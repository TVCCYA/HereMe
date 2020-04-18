import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/user_profile/new_profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';

class UserResult extends StatelessWidget {
  final User user;
  final String locationLabel;

  UserResult({this.user, this.locationLabel});

  toProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewProfile(user: user, locationLabel: locationLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toProfile(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          cachedUserResultImage(user.profileImageUrl ?? '', 70, false),
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
      child: cachedUserResultImage(user.profileImageUrl, 40, false),
    );
  }
}
