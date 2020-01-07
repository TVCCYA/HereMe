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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(user.username ?? '', style: kAppBarTextStyle.copyWith(fontSize: 20)),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  height: screenHeight / 1.85,
                  child: cachedUserResultImage(user.profileImageUrl, 15),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Image.asset(
                    'images/live.png',
                    color: Colors.white,
                    scale: 6.0,
                  )
                )
              ],
            ),
          ),
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
      child: cachedUserResultImage(user.profileImageUrl, 5),
    );
  }
}
