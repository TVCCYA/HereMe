import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class RecentUpload extends StatelessWidget {
  RecentUpload(
      {this.title, this.url, this.imageUrl, this.onTap, this.creationDate});

  final String title;
  final String url;
  final String imageUrl;
  final Function onTap;
  final int creationDate;

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
          contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
          title: Text(
            title,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            url,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorBlue,
            ),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              imageUrl,
              scale: 3.5,
              fit: BoxFit.cover,
            ),
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