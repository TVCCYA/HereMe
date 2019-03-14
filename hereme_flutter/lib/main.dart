import 'package:flutter/material.dart';
import 'TabController.dart';

void main() {
  //todo move _isUserLoggedIn() here

  runApp(
      new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new NavControllerState(),
  ));
}
