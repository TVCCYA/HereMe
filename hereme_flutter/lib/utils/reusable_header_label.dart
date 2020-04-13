import 'package:flutter/material.dart';
import '../constants.dart';

class ReusableHeaderLabel extends StatelessWidget {
  ReusableHeaderLabel(this.title, {this.top = 20.0, this.left = 12.0, this.bottom = 8.0});

  final String title;
  final double top;
  final double left;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, left: left, bottom: bottom),
      child: Text(title, style: kAppBarTextStyle),
    );
  }
}