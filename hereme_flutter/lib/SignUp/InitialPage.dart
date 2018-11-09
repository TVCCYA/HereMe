import 'package:flutter/material.dart';

class InitialPage extends StatefulWidget {

  InitialPage({Key key}) : super(key: key);
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with SingleTickerProviderStateMixin{
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signIn = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
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
    final SignUp = Padding(
              padding: EdgeInsets.all(3.0),
              child: Material(
                borderRadius: BorderRadius.circular(30.0),
                shadowColor: Colors.black,
                elevation: 5.0,
                child: MaterialButton(
                  minWidth: 300.0,
                  height: 42.0,
                  onPressed: () => _signUp(),
                  color: Colors.black,
                  child: Text('sign Up',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
    );

    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'HereMe',
          style: new TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: new ListView(
          reverse: false,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
//            SizedBox(height: 5.0),
            signIn,
            SignUp,
          ].toList(),
        ),
    );
  }



  Future _signUp() async {

    if(passwordInput.text.length >= 6){

//      var route = new MaterialPageRoute(
//          builder: (BuildContext context) => new createUser(
//            value: happy,
//            primary: primarySchoolColor,
//            secondary: secondarySchoolColor,
//            email: emailInput.text,
//            password: passwordInput.text,
//          ));
//      Navigator.of(context).push(route);
    } else {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
              content: new Text(
                "Your Password Must Be Six Characters Long",
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Ok"),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]
          )
      );
    };
  }

//  @override
//  void dispose() {
//    // Clean up the controller when the Widget is disposed
////    emailInput.dispose();
////    passwordInput.dispose();
//    super.dispose();
//  }
}