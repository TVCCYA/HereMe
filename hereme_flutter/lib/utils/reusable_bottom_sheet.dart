import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';

class ReusableBottomActionSheetListTile extends StatelessWidget {
  ReusableBottomActionSheetListTile(
      {@required this.iconData, @required this.title, @required this.onTap, this.color});

  final IconData iconData;
  final String title;
  final Function onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: ListTile(
        dense: true,
        leading: Icon(iconData, color: color ?? kColorLightGray),
        title: Text(
          title,
          style: kDefaultTextStyle.copyWith(color: color ?? kColorBlack71),
        ),
        onTap: onTap,
      ),
    );
  }
}