import 'package:flutter/material.dart';
import 'package:hereme_flutter/GridFind/home.dart';

void main() {
  //todo move _isUserLoggedIn() here
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
//      home: AltUserProfile(),
        home: Home(),
    ),
  );
}
