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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: Container(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 15.0),
        itemCount: allContacts.length,
        itemBuilder: (BuildContext content, int index) {
          Settings contact = allContacts[index];
          return settingsListTile(contact);
        });
  }
}

class settingsListTile extends ListTile {
  settingsListTile(Settings option)
      : super(
    title: Text(option.setting),
    leading: new Container(
      height: 50.0,
      width: 50.0,
      child: new Image.asset(option.icon),
    ),
  );
}

List<Settings> allContacts = [
  Settings(setting: 'Link Your Accounts', icon: 'images/settings/linkGray180.png'),
//  Settings(setting: 'Saved Them', icon: 'images/settings/.png'),
  Settings(setting: 'My Local Photos', icon: 'images/settings/localPhoto180.png'),
  Settings(setting: 'HideMe', icon: 'images/settings/incognito180.png'),
  Settings(setting: 'Tell Your Friends', icon: 'images/settings/share180.png'),
  Settings(setting: 'Rate HereMe', icon: 'images/settings/star180.png'),
  Settings(setting: 'Help & Support', icon: 'images/settings/umbrella180.png'),
  Settings(setting: 'check out our apps', icon: 'images/settings/glasses180.png'),
];

//class MenuListView extends StatefulWidget {
//  @override
//  _MenuListViewState createState() => _MenuListViewState();
//}
//
//class _MenuListViewState extends State<MenuListView> {
//  @override
//  Widget build(BuildContext context) {
//    new Scaffold(
//      appBar: new AppBar(
//        title: new Text("Settings"),
//      ),
//    );
//  }
//}
