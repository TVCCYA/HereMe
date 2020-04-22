import 'package:flutter/material.dart';
import '../constants.dart';

class ReusableHeaderLabel extends StatelessWidget {
  ReusableHeaderLabel(this.title, {this.top = 20.0, this.left = 12.0, this.bottom = 8.0, this.textColor = kColorBlack62});

  final String title;
  final double top;
  final double left;
  final double bottom;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, left: left, bottom: bottom),
      child: Text(title, style: kAppBarTextStyle.copyWith(fontSize: 20, color: textColor)),
    );
  }
}