import 'package:flutter/material.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/registration/initial_page.dart';

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
