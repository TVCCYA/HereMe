import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';

class ReusableButton extends StatelessWidget {
  ReusableButton({this.title, @required this.onPressed, this.textColor});

  final String title;
  final Function onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: MaterialButton(
        splashColor: kColorExtraLightGray,
        highlightColor: Colors.transparent,
        onPressed: onPressed,
        child: Text(
          title,
          style: kAppBarTextStyle.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class ReusableRoundedCornerButton extends StatelessWidget {
  const ReusableRoundedCornerButton({
    @required this.text,
    @required this.onPressed,
    @required this.width,
    this.height = 30.0,
    this.backgroundColor = Colors.transparent,
    this.textColor = kColorBlack71,
    this.splashColor,
  });

  final String text;
  final Function onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Color splashColor;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: width,
      height: height,
      child: FlatButton(
        child: Text(
          text,
          style: kDefaultTextStyle.copyWith(color: textColor),
        ),
        color: backgroundColor,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: textColor),
          borderRadius: BorderRadius.circular(5.0),
        ),
        splashColor: splashColor ?? Colors.black.withOpacity(0.05),
        highlightColor: Colors.transparent,
      ),
    );
  }
}