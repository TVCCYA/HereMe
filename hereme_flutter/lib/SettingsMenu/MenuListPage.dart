import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class Settings {
  Settings({this.setting, this.icon});
  final String setting;
  final String icon;
}

class ListPage extends StatelessWidget  {
  ListPage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: new Text("Settings", style: new TextStyle(color: Colors.offBlack),),
        iconTheme: IconThemeData(
          color: Colors.mainPurple, //change your color here
        ),
      ),
      body: Container(
        child: new ListView(
            children: new List.generate(8, (int index){
              return _buildContent();
            }),
      ),
      )
    );
  }

  Widget _buildContent() {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        itemCount: allSettings.length,
        itemBuilder: (BuildContext content, int index) {
          Settings contact = allSettings[index];
          return settingsListTile(contact);
        });
  }
}

class settingsListTile extends ListTile {
  settingsListTile(Settings option)
      : super(
    title: Text(option.setting, style: new TextStyle(color: Colors.offBlack, fontWeight: FontWeight.bold, fontSize: 14.0),),
    leading: new Container(
      height: 45.0,
      width: 45.0,
      child: new Image.asset(option.icon),
    ),
    onTap: () {
//      print();
    },
    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 20.0)
  );
}

List<Settings> allSettings = [
  Settings(setting: 'Link Your Accounts', icon: 'images/settings/linkGray180.png'),
  Settings(setting: 'Saved Them', icon: 'images/settings/bookmarkFilled180.png'),
  Settings(setting: 'My Local Photos', icon: 'images/settings/localPhoto180.png'),
  Settings(setting: 'HideMe', icon: 'images/settings/incognito180.png'),
  Settings(setting: 'Tell Your Friends', icon: 'images/settings/share180.png'),
  Settings(setting: 'Rate HereMe', icon: 'images/settings/star180.png'),
  Settings(setting: 'Help & Support', icon: 'images/settings/umbrella180.png'),
  Settings(setting: 'check out our apps', icon: 'images/settings/glasses180.png'),
];
