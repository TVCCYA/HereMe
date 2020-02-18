import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';

class LinkedAccount extends StatelessWidget {
  LinkedAccount(
      {@required this.accountUsername,
        this.iconString,
        this.onTap,
        this.accountUrl});

  final String accountUsername;
  final String iconString;
  final String accountUrl;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // separator line
        Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Container(height: 0.5, color: kColorExtraLightGray),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
          title: Text(
            accountUsername,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle,
          ),
          subtitle: Text(
            accountUrl,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kDefaultTextStyle.copyWith(
              fontSize: 12.0,
              color: kColorBlue.withOpacity(0.75),
            ),
          ),
          leading: Image.asset(
            kIconPath(iconString),
            scale: 3.5,
          ),
          onTap: onTap,
          trailing: Icon(
            Icons.chevron_right,
            size: 24,
            color: kColorLightGray,
          ),
        ),
      ],
    );
  }
}