import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import './ResetPassword.dart';
import '../TabController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final FocusNode emailFocus = FocusNode();
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
              FocusScope.of(context).requestFocus(passwordFocus);
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

    final errorText = new Container(
      alignment: Alignment.topCenter,
      child: new Text(
        inputErrorText,
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 14.0, fontStyle: FontStyle.normal, color: Colors.red),
      ),
    );

    final resetPasswordButton = Container(
      alignment: FractionalOffset.bottomCenter,
      padding: EdgeInsets.only(bottom: 5.0),
      width: 88.0,
      height: 36.0,
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPassword()),
            );
          },
          child: new Column(
//            crossAxisAlignment: CrossAxisAlignment.baseline,
//            mainAxisSize: MainAxisSize.max,
//            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Forgot Your Password?',
                style: TextStyle(
                  color: Colors.mainBlue,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
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
              color: Colors.mainBlue,
              child: new Text("Sign In"),
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
                  passwordRow,
                  SizedBox(height: 5.0),
                  errorText,
                  SizedBox(height: MediaQuery.of(context).size.height - 415.0),
                  resetPasswordButton
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
    if (emailInput.text.contains("@") && passwordInput.text.length >= 6) {
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
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var succeed = true;

    //clears the red text to notify the user that their changes were indeed submitted
    setState(() {
      inputErrorText = "";
    });

    await _auth
        .signInWithEmailAndPassword(
            email: emailInput.text, password: passwordInput.text)
        .catchError((error) {
      int errorLength = error.toString().length;
      String errorToString = error.toString().substring(50, errorLength - 1);

      setState(() {
        inputErrorText = errorToString;
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });

      succeed = false;
    }).then((user) {
      if (succeed == true) {
        print("signed in successfuly");
        _saveUserSharedPref();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => new NavControllerState()),
                (Route<dynamic> route) => false);
      }
    });
  }

  _saveUserSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final socialMediasReference = await Firestore.instance.collection("users").document(user.uid).get();


    for(int i = 0; i < socialMediasReference.data.length; i++){
      if(socialMediasReference.data.keys.elementAt(i).toString() == "username") {
        print("username ${socialMediasReference.data.values.elementAt(i).toString()}");
        await prefs.setString("username", "${socialMediasReference.data.values.elementAt(i).toString()}");
      } else if(socialMediasReference.data.keys.elementAt(i).toString() == "profileImageUrl") {
        print("photo url ${socialMediasReference.data.values.elementAt(i).toString()}");
        await prefs.setString("photoUrl", "${socialMediasReference.data.values.elementAt(i).toString()}");
      }
    }

//    print("username ${socialMediasReference.data}");
//    print("photoUrl ${socialMediasReference.data.containsKey("profileImageUrl")}");
//
//    await prefs.setString("uid", "${user.uid}");
//    await prefs.setString("name", "${socialMediasReference.data.containsKey("username")}");
//    await prefs.setString("photoUrl", "${socialMediasReference.data.containsKey("profileImageUrl")}");

  }
  
}
