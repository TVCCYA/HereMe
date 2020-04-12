import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/live_chat/add_live_chat.dart';
import 'package:hereme_flutter/settings/choose_account.dart';
import 'package:hereme_flutter/updates/add_update.dart';
import 'package:hereme_flutter/utils/settings_tile.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/settings//help_support.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';

class ListPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
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
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: Column(children: <Widget>[
        SettingsTile(
          label: 'Link Account',
          color: kColorRed.withOpacity(1.0),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ChooseAccount())),
        ),
        SettingsTile(
          label: 'Add Latest Post',
          color: kColorRed.withOpacity(0.9),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddLatest())),
        ),
        SettingsTile(
          label: 'Create Live Chat',
          color: kColorRed.withOpacity(0.8),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddLiveChat())),
        ),
        SettingsTile(
          label: 'Hide Me',
          color: kColorRed.withOpacity(0.7),
          onTap: () => kHandleHideMe(_scaffoldKey),
        ),
        SettingsTile(
          label: 'Tell Your Friends',
          color: kColorRed.withOpacity(0.6),
          onTap: () => _handleShare(),
        ),
        SettingsTile(
          label: 'Rate HereMe',
          color: kColorRed.withOpacity(0.5),
          onTap: () => _handleRate(),
        ),
        SettingsTile(
          label: 'Help & Support',
          color: kColorRed.withOpacity(0.4),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SupportPage())),
        ),
        Theme(
          data: kTheme(context),
          child: InkWell(
            onTap: () => _handleLogout(context),
            child: Container(
              color: kColorRed.withOpacity(0.4),
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
  
  _handleShare() {
    Share.share('Spread the word about Spred!');
  }

  _handleRate() {
    LaunchReview.launch(
        androidAppId: "com.TVCCYA.HereMe",
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
