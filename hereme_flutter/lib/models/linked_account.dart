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
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: ListTile(
        dense: true,
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
    );
  }
}