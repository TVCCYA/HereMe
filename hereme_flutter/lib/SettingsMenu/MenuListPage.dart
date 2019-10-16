import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../registration//initial_page.dart';
import './SocialMediasList.dart';
import 'package:hereme_flutter/contants/constants.dart';

class MenuOptions {
  MenuOptions({this.setting, this.icon});
  final String setting;
  final String icon;
}

class ListPage extends StatelessWidget  {
  ListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: new Text("Settings", style: new TextStyle(color: kColorOffBlack),),
        iconTheme: IconThemeData(
          color: kColorPurple,
        ),
      ),
      body: new ListView.builder(
              itemCount: allSettings.length,
              itemBuilder: (BuildContext content, int index) {
                MenuOptions option = allSettings[index];
                return SettingsListTile(option, context);
              }),
    );
  }
}

class SettingsListTile extends ListTile {
  SettingsListTile(MenuOptions option, context)
      : super(
    title: Text(option.setting, style: new TextStyle(color: kColorOffBlack, fontWeight: FontWeight.bold, fontSize: 14.0),),
    leading: new Container(
      height: 45.0,
      width: 45.0,
      child: new Image.asset(option.icon),
    ),
    onTap: () {
      print(option.setting);
      switch(option.setting){
        case 'Link Your Accounts': {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MediasList()));
        }
        break;
        case 'Saved Them': {

        }
        break;
        case 'HideMe': {

        }
        break;
        case 'Tell Your Friends': {

        }
        break;
        case 'Rate HereMe': {
          //todo Apps have to be published for the app to be found correctly
        }
        break;
        case 'Help & Support': {

        }
        break;
        case 'Logout': {
          final FirebaseAuth _auth = FirebaseAuth.instance;
            _auth.signOut().catchError((error) {
              print("error signing out i guess :/");
            }).then((_){
              print("successful logout");
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (BuildContext context) => InitialPage()),
                      (Route<dynamic> route) => false);
            });
        }
        break;
      }
    },
    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0)
  );
}

List<MenuOptions> allSettings = [
  MenuOptions(setting: 'Link Your Accounts', icon: 'images/settings/linkGray180.png'),
  MenuOptions(setting: 'Saved Them', icon: 'images/settings/bookmarkFilled180.png'),
  MenuOptions(setting: 'HideMe', icon: 'images/settings/incognito180.png'),
  MenuOptions(setting: 'Tell Your Friends', icon: 'images/settings/share180.png'),
//  MenuOptions(setting: 'Rate HereMe', icon: 'images/settings/star180.png'),
  MenuOptions(setting: 'Help & Support', icon: 'images/settings/umbrella180.png'),
  MenuOptions(setting: 'Logout', icon: 'images/settings/logout180.png')
];
