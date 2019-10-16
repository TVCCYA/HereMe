import 'package:flutter/material.dart';
import 'package:hereme_flutter/contants/constants.dart';

class ReusableBottomActionSheetListTile extends StatelessWidget {
  ReusableBottomActionSheetListTile(
      {@required this.iconData, @required this.title, @required this.onTap});

  final IconData iconData;
  final String title;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: ListTile(
        leading: Icon(iconData, color: kColorLightGray),
        title: Text(
          title,
          style: kDefaultTextStyle,
        ),
        onTap: onTap,
      ),
    );
  }
}