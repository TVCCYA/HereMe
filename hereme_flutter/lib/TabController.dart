import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './GridFind/GridFindCollectionPage.dart' as gridFind;
import './UserProfile/ProfilePage/UserProfilePage.dart' as userProfile;

//class NavController extends StatefulWidget {
//  @override
//  NavControllerState createState() => new NavControllerState();
//}

class NavControllerState extends StatelessWidget {

//  TabController controller;
//
//  @override
//  void initState() {
//    super.initState();
//    controller = new TabController(vsync: this, length: 2);
//  }
//
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
              new userProfile.UserProfile(),
            ],
          ),
          bottomNavigationBar: new TabBar(
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
          backgroundColor: Colors.white,
        ),
      ),
    );
  }






//  Widget build(BuildContext context) {
//    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//    return new Scaffold(
//        bottomNavigationBar: new Material(
//            color: Colors.deepOrange,
//            child: new TabBar(
//                controller: controller,
//                tabs: <Tab>[
//                  new Tab(icon: new Icon(Icons.arrow_forward)),
//                  new Tab(icon: new Icon(Icons.arrow_back)),
//                ]
//            )
//        ),
//        body: new TabBarView(
//            controller: controller,
//            children: <Widget>[
//              new gridFind.GridFindCollectionPage(),
//              new userProfile.UserProfile()
//            ]
//        )
//    );
//  }
}