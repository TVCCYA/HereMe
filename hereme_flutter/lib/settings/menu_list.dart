import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/utils/settings_tile.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/settings//help_support.dart';
import 'add_account.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:launch_review/launch_review.dart';

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Settings",
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: Column(children: <Widget>[
        SettingsTile(
          label: 'Link Account',
          color: kColorPurple.withOpacity(1.0),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddAccount())),
        ),
        SettingsTile(
          label: 'Saved Them',
          color: kColorPurple.withOpacity(0.9),
          onTap: () => print('ok'),
        ),
        SettingsTile(
          label: 'Hide Me',
          color: kColorPurple.withOpacity(0.8),
          onTap: () => print('hide me'),
        ),
        SettingsTile(
          label: 'Tell Your Friends',
          color: kColorPurple.withOpacity(0.7),
          onTap: () => print('share'),
        ),
        SettingsTile(
          label: 'Rate HereMe',
          color: kColorPurple.withOpacity(0.6),
          onTap: () => _handleRateMe(),
        ),
        SettingsTile(
          label: 'Help & Support',
          color: kColorPurple.withOpacity(0.5),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SupportPage())),
        ),
        SettingsTile(
          label: 'Send Us Feedback',
          color: kColorPurple.withOpacity(0.4),
          onTap: () => print('feedback'),
        ),
        Theme(
          data: kTheme(context),
          child: InkWell(
            onTap: () => _handleLogout(context),
            child: Container(
              color: kColorPurple.withOpacity(0.4),
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: Center(
                child: Text(
                  'Logout',
                  style: kAppBarTextStyle.copyWith(
                      color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  _handleRateMe() {
    LaunchReview.launch(
        androidAppId: "com.TVCCYA.HereMe.heremeflutter",
        iOSAppId: "1392161162");
  }

  _handleLogout(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut().catchError((error) {
      print("error signing out i guess :/");
    }).then((_) {
      print("successful logout");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => InitialPage()),
          (Route<dynamic> route) => false);
    });
  }
}
