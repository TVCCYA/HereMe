import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:launch_review/launch_review.dart';
import 'package:hereme_flutter/SettingsMenu/Help&Support.dart';
import 'package:hereme_flutter/SignUp&In/InitialPage.dart';
import './SocialMediasList.dart';

class ListPage extends StatelessWidget {
  ListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: new Text(
          "Settings",
          style: new TextStyle(color: Colors.offBlack),
        ),
        iconTheme: IconThemeData(
          color: Colors.mainPurple,
        ),
      ),
      body: new Container(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Column(children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MediasList()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 1.0),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Link Your Accounts",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.9),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Saved Them",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.85),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Hide Me",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.8),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Tell Your Friends",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _handleRateMe(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.75),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Rate HereMe",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SupportPage()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.7),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Help & Support",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.65),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Share Your Feedback",
                    style: new TextStyle(
                        color: Colors.offBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _handleLogout(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(111, 89, 194, 0.6),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 45.0,
//                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Logout",
                            style: new TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0), textAlign: TextAlign.center),
                      ]
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

    _handleRateMe() {
      LaunchReview.launch(androidAppId: "com.TVCCYA.HereMe.heremeflutter",iOSAppId: "1392161162");
    }

    _handleLogout(BuildContext context) {
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

}
