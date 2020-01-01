import 'package:flutter/material.dart';
import 'package:hereme_flutter/constants.dart';

class ReusableRegistrationTextField extends StatelessWidget {
  ReusableRegistrationTextField(
      {@required this.onSubmitted,
        @required this.onChanged,
        this.focusNode,
        this.keyboardType,
        this.textInputAction,
        this.hintText,
        this.icon,
        this.obscureText,
        this.maxLength,
        this.color
      });

  final FocusNode focusNode;
  final Function onChanged;
  final Function onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final int maxLength;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      onChanged: onChanged,
      autofocus: true,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      cursorColor: kColorLightGray,
      keyboardType: keyboardType,
      style: kDefaultTextStyle.copyWith(color: color ?? kColorBlack71),
      autocorrect: false,
      textInputAction: textInputAction,
      obscureText: obscureText ?? false,
      decoration: kRegistrationInputDecoration.copyWith(
        hintText: hintText,
        hintStyle: kDefaultTextStyle.copyWith(color: kColorLightGray),
        icon: Icon(
          icon,
          color: kColorRed,
        ),
      ),
    );
  }
}