import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';

class ReusableButton extends StatelessWidget {
  ReusableButton({this.title, @required this.onPressed, this.textColor});

  final String title;
  final Function onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.white,
        child: MaterialButton(
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
          onPressed: onPressed,
          child: Text(
            title,
            style: kAppBarTextStyle.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}