import 'package:flutter/material.dart';
import 'package:hereme_flutter/SignUp/InitialPage.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new InitialPage(),
//    home: new settingPage(),
    theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.white,
        hintColor: Colors.white
    ),
  ));
}