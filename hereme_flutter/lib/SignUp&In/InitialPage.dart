import 'package:flutter/material.dart';
import 'package:hereme_flutter/SignUp&In/SignIn.dart';
import 'package:hereme_flutter/SignUp&In/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InitialPage extends StatefulWidget {
  InitialPage({Key key}) : super(key: key);
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signInButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Material(
        shadowColor: Colors.black,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
//            _signInWithEmail();
          },
          color: Colors.black,
          child: Text('Sign In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final SignUpButton = Padding(
      padding: EdgeInsets.all(3.0),
      child: Material(
        shadowColor: Colors.black,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 300.0,
          height: 42.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUp()),
            );
          },
          color: Colors.black,
          child: Text('Sign Up', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    //todo remove this function and import when appropriate
    final emailLogout = Padding(
      padding: EdgeInsets.all(3.0),
      child: Material(
        shadowColor: Colors.black,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 300.0,
          height: 42.0,
          onPressed: () {
            final FirebaseAuth _auth = FirebaseAuth.instance;
            setState(() {
              _auth.signOut().catchError((error) {
                print("error signing out i guess :/");
              }).then((_){
                print("successful logout");
              });
            });
          },
          color: Colors.black,
          child: Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: new ListView(
        reverse: false,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          SizedBox(height: 50.0),
          signInButton,
          SignUpButton,
          emailLogout
        ].toList(),
      ),
    );
  }
}
