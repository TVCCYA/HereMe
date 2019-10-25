import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/user_profile/profile_page/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contants/constants.dart';
import 'models/user.dart';

class NavController extends StatefulWidget {
  @override
  _NavControllerState createState() => _NavControllerState();
}

class _NavControllerState extends State<NavController> {
  final auth = FirebaseAuth.instance;
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    handleLoggedIn();
  }

  getCurrentUser() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    if (!doc.exists) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitialPage()));
    }
    currentUser = User.fromDocument(doc);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', currentUser.username);
    await prefs.setString('profileImageUrl', currentUser.profileImageUrl);
  }

  handleLoggedIn() async {
    if (auth != null) {
      getCurrentUser();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: kColorOffWhite,
        title: new Text(
          "HereMe",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: kColorPurple,
            fontFamily: 'Arimo',
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.user, color: kColorBlue),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(user: currentUser))),
          ),
        ],
      ),
    );
  }
}
