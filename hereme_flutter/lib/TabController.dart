import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './GridFind/GridFindCollectionPage.dart' as gridFind;
import './UserProfile/ProfilePage/UserProfilePage.dart' as userProfile;

bool keepGridAlive;
bool keepProfileAlive;

class NavControllerState extends StatelessWidget {

//  TabController controller;

  @override
  void initState() {
    keepGridAlive = true;
    keepProfileAlive = true;
  }

//  @override
//  void dispose() {
//    controller.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return new MaterialApp(
      color: Colors.yellow,
      home: DefaultTabController(
        length: 2,
        child: new Scaffold(
          body: TabBarView(
            children: [
              new gridFind.GridFindCollectionPage(),
              new userProfile.UserProfile()
            ],
          ),
          bottomNavigationBar: new SafeArea(
            child: new TabBar(
              tabs: [
                Tab(
                  icon: new Icon(Icons.home),
                ),
                Tab(
                  icon: new Icon(Icons.rss_feed),
                ),
              ],
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.all(5.0),
              indicatorColor: Colors.purple,
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

}