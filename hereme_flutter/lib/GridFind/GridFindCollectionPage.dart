import 'package:flutter/material.dart';
import '../SignUp&In/InitialPage.dart';
import '../UserProfile/ProfilePage/UserProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GridFindCollectionPage extends StatefulWidget {
  @override
  _GridFindCollectionPageState createState() => _GridFindCollectionPageState();
}

class _GridFindCollectionPageState extends State<GridFindCollectionPage> {

  @override
  void initState() {
    super.initState();
    _isUserLoggedIn();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.offWhite,
        title: new Text(
          "HereMe",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.mainPurple,
            fontStyle: FontStyle.normal,
            fontSize: 24.0,
//            fontFamily: 'Avenir-Heavy',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(children: _getListData()),
    );
  }

  void _isUserLoggedIn() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.currentUser().then((value) {
      if (value == null) {
        var route = new MaterialPageRoute(
            builder: (BuildContext context) => new InitialPage());
        Navigator.of(context).push(route);
      } else {
        //Todo successful user log in
      }
    });
  }

  _getListData() {
    List<Widget> widgets = [];
    for (int i = 0; i < 100; i++) {
      widgets
          .add(Padding(padding: EdgeInsets.all(10.0), child: Text("Row $i")));
    }
    return widgets;
  }

}
