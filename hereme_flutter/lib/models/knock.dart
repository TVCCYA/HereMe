import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:flutter/material.dart';

class Knock extends StatelessWidget {
  final String username;
  final String imageUrl;
  final Function onTap;
  final int creationDate;

  Knock({
    this.username,
    this.imageUrl,
    this.onTap,
    this.creationDate,
  });

  String date() {
    final timeAgo = TimeAgo.getTimeAgo(creationDate ~/ 1000);
    return timeAgo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          contentPadding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
          title: Text(
            username,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: cachedNetworkImage(imageUrl),
          ),
          onTap: onTap,
          trailing: Text(
            date(),
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorLightGray,
            ),
          ),
        ),
        // separator line
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(height: 0.5, color: kColorExtraLightGray),
        )
      ],
    );
  }
}
