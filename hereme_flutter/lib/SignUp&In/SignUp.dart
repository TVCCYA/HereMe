import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/SignUp&In/PhotoAdd.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailInput = TextEditingController();
  final firstNameInput = TextEditingController();
  final passwordInput = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool hideContinueButton = true;
  String inputErrorText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //removes status bar
    SystemChrome.setEnabledSystemUIOverlays([]);

    final HereMeText = new Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
      alignment: Alignment.topCenter,
      child: new Text(
        'HereMe',
        style: new TextStyle(
            fontSize: 70.0,
            fontStyle: FontStyle.normal,
            fontFamily: 'Berlin-Sans',
            color: Colors.black),
      ),
    );

    final emailRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(00.0, 10.0, 45.0, 0.0),
          alignment: Alignment.centerLeft,
          child: new Text(
            'Email',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.offBlack),
          ),
        ),
        new Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              emailFocus.unfocus();
              FocusScope.of(context).requestFocus(firstNameFocus);
            },
            onChanged: (_) {
              _checkForCompletion();
            },
            focusNode: emailFocus,
            controller: emailInput,
            style: new TextStyle(fontSize: 16.0, color: Colors.black),
            autofocus: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Example@mail.com',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
            ),
          ),
        )),
      ],
    );

    final firstNameRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(00.0, 10.0, 0.0, 0.0),
          alignment: Alignment.centerLeft,
          child: new Text(
            'First Name',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.offBlack),
          ),
        ),
        new Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
          child: TextField(
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              firstNameFocus.unfocus();
              FocusScope.of(context).requestFocus(passwordFocus);
            },
            onChanged: (_) {
              _checkForCompletion();
            },
            focusNode: firstNameFocus,
            controller: firstNameInput,
            style: new TextStyle(fontSize: 16.0, color: Colors.black),
            autofocus: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'What\'s Your Name?',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
            ),
          ),
        )),
      ],
    );

    final passwordRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(00.0, 10.0, 9.0, 0.0),
          alignment: Alignment.centerLeft,
          child: new Text(
            'Password',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.offBlack),
          ),
        ),
        new Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
          child: TextField(
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              _continueAction();
            },
            onChanged: (_) {
              _checkForCompletion();
            },
            obscureText: true,
            focusNode: passwordFocus,
            controller: passwordInput,
            style: new TextStyle(fontSize: 16.0, color: Colors.black),
            autofocus: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '••••••',
              contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
            ),
          ),
        )),
      ],
    );

    final termsOfUseButton = SizedBox(
        width: 88.0,
        height: 36.0,
        child: GestureDetector(
          onTap: () {
            _launchURL();
          },
          child: new Column(
            children: <Widget>[
              Text('Terms of Use',
              style: TextStyle(
                color: Colors.mainBlue,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
          ),
            ],
          )
      ),
    );


    final errorText = new Container(
      alignment: Alignment.topCenter,
      child: new Text(
        inputErrorText,
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 14.0,
            fontStyle: FontStyle.normal,
            color: Colors.red
        ),
      ),
    );

    final continueButton = new SizedBox(
      width: double.infinity,
      height: 45.0,
      child: hideContinueButton
          ? null
          : new RaisedButton(
              onPressed: () {
                _continueAction();
              },
              textColor: Colors.white,
              color: Colors.mainPurple,
              child: new Text("Agree to Terms & Continue"),
            ),
    );

    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.offWhite,
      ),
      backgroundColor: Colors.offWhite,
      body: new GestureDetector(
        onTap: () {
          // Hides keyboard when tapping off a text field
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Expanded(
              child: new ListView(
                //primary makes the page not scroll
                primary: false,
                padding: EdgeInsets.only(left: 10.0),
                children: <Widget>[
                  HereMeText,
                  SizedBox(height: 30.0),
                  emailRow,
                  SizedBox(height: 8.0),
                  firstNameRow,
                  SizedBox(height: 8.0),
                  passwordRow,
                  SizedBox(height: 15.0),
                  termsOfUseButton,
                  SizedBox(height: 5.0),
                  errorText
                ].toList(),
              ),
            ),
            continueButton
          ],
        ),
      ),
    );
  }

  _checkForCompletion() {
    if (emailInput.text.contains("@") &&
        firstNameInput.text.length != 0 &&
        passwordInput.text.length != 0) {
      setState(() {
        hideContinueButton = false;
      });
    } else {
      setState(() {
        hideContinueButton = true;
      });
    }
  }

  _continueAction() async {
    var succeed = true;

    //clears the red text to notify the user that their changes were indeed submitted
    setState(() {
      inputErrorText = "";
    });

    await _auth.createUserWithEmailAndPassword(email: emailInput.text, password: passwordInput.text).catchError((error) {
      int errorLength = error.toString().length;
      String errorToString = error.toString().substring(50, errorLength - 1);

      setState(() {
        inputErrorText = errorToString;
      });

      succeed = false;
    }).then((user) {
      if (succeed == true) {
        _saveUserFirebase();
        _saveUserSharedPref();
      }
    });
  }

  _saveUserFirebase() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final userReference = Firestore.instance.collection("users").document("${user.uid}");

    Map<String, String> signUpUserData = <String, String>{
      "username" : firstNameInput.text,
      "uid" : user.uid,
    };

    userReference.setData(signUpUserData).whenComplete(() {
      print("User Added");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new PhotoAdd(uid: user.uid)),
      );
    }).catchError((e) => print(e));
  }

  _saveUserSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await prefs.setString("name", "$firstNameInput");
    await prefs.setString("uid", "${user.uid}");
    await prefs.setString("photoUrl", "");
  }

  _launchURL() async {
    const url = "https://termsfeed.com/terms-conditions/eb83aa859848185014a8c99fb5fbfadb";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
