import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  SupportPage({Key key}) : super(key: key);

  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: new Text(
          "Help & Support",
          style: new TextStyle(color: kColorBlack105),
        ),
        iconTheme: IconThemeData(
          color: kColorPurple,
        ),
      ),
      body: new Container(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Column(children: <Widget>[
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(71, 106, 188, 1.0),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Blocked Users",
                    style: new TextStyle(
                        color: kColorBlack105,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openPrivacyPolicy(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(71, 106, 188, 0.9),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Privacy Policy",
                    style: new TextStyle(
                        color: kColorBlack105,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openTermsConditions(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(71, 106, 188, 0.8),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Terms & Conditions",
                    style: new TextStyle(
                        color: kColorBlack105,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _jankAlert(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(71, 106, 188, 0.7),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Change HereMe Name",
                    style: new TextStyle(
                        color: kColorBlack105,
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
                  color: Color.fromRGBO(71, 106, 188, 0.6),
                  width: 10.0,
                  height: 55.0,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                Text("Reset Password",
                    style: new TextStyle(
                        color: kColorBlack105,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _deleteAlert(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(71, 106, 188, 0.5),
                  width: MediaQuery.of(context).size.width,
                  height: 45.0,
//                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Delete HereMe Account",
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

  _jankAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "TextField in Dialog"),
              onSubmitted: (_) {
                if(_textFieldController.text.length > 1) {
                  _handleNameChange(context);
                } else {
                  print("alert the user their name must be a minimum of 3 characters");
                }
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _openPrivacyPolicy() async {
    String url = "https://termsfeed.com/privacy-policy/82297978c6805adec572a51e13a5df2a";

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }

  _openTermsConditions() async {
    String url = "https://termsfeed.com/terms-conditions/eb83aa859848185014a8c99fb5fbfadb";

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }

  _handleNameChange(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final userReference = Firestore.instance.collection("users").document(
        "${user.uid}");

    Map<String, String> nameData = <String, String>{
      "username": _textFieldController.text,
    };

    userReference.updateData(nameData).whenComplete(() {
      print("Name Changed");
//      _updatePreferences(context);
    }).catchError((e) => print(e));
  }

//  _updatePreferences(BuildContext context) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString("name", "${_textFieldController.text}").whenComplete(() {
//      Navigator.pushAndRemoveUntil(context,
//          MaterialPageRoute(builder: (context) => new NavControllerState()),
//              (Route<dynamic> route) => false);
//    });
//  }

  _deleteAlert(BuildContext context) async {

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: FlatButton(
              child: new Text('OKAYYY'),
              onPressed: () {
                _handleAccountDelete();
//                Navigator.pushAndRemoveUntil(context,
//                    MaterialPageRoute(builder: (context) => new InitialPage()),
//                        (Route<dynamic> route) => false);
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _handleAccountDelete() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final userReference = Firestore.instance.collection("users").document("${user.uid}");

    _storage.ref().child("profile_images/${user.uid}").delete();
    userReference.delete();
  }

}