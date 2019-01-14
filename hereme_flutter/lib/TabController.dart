import 'package:flutter/material.dart';
import './GridFind/GridFindCollectionPage.dart' as gridFind;
import './UserProfile/ProfilePage/UserProfilePage.dart' as userProfile;

class NavController extends StatefulWidget {
  @override
  NavControllerState createState() => new NavControllerState();
}

class NavControllerState extends State<NavController> with SingleTickerProviderStateMixin {

  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//        appBar: new AppBar(
//            title: new Text("Pages"),
//            backgroundColor: Colors.deepOrange,
//            bottom: new TabBar(
//                controller: controller,
//                tabs: <Tab>[
//                  new Tab(icon: new Icon(Icons.arrow_forward)),
//                  new Tab(icon: new Icon(Icons.arrow_downward)),
//                  new Tab(icon: new Icon(Icons.arrow_back)),
//                ]
//            )
//        ),
        bottomNavigationBar: new Material(
            color: Colors.deepOrange,
            child: new TabBar(
                controller: controller,
                tabs: <Tab>[
                  new Tab(icon: new Icon(Icons.arrow_forward)),
                  new Tab(icon: new Icon(Icons.arrow_back)),
                ]
            )
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new gridFind.GridFindCollectionPage(),
//              new second.Second(),
              new userProfile.UserProfile()
            ]
        )
    );
  }
}