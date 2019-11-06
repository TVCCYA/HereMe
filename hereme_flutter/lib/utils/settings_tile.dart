import 'package:flutter/material.dart';

import '../constants.dart';


class SettingsTile extends StatelessWidget {
  final String label;
  final Color color;
  final Function onTap;
  SettingsTile({this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kTheme(context),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: color,
              width: 10.0,
              height: 50.0,
            ),
            Padding(padding: EdgeInsets.only(left: 16.0)),
            Text(label, style: kDefaultTextStyle)
          ],
        ),
      ),
    );
  }
}