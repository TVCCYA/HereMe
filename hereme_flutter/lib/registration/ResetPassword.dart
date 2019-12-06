import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hereme_flutter/constants.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({Key key}) : super(key: key);
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool hideSendButton = true;
  bool showSentText = false;
  String inputErrorText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //removes status bar
    SystemChrome.setEnabledSystemUIOverlays([]);

    final ResetText = new Container(
      padding: EdgeInsets.fromLTRB(10.0, 100.0, 10.0, 10.0),
      alignment: Alignment.topCenter,
      child: new Text(
        'Email Me the Link',
        style: new TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
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
                color: kColorOffBlack),
          ),
        ),
        new Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.send,
                onEditingComplete: () {
                  _continueAction();
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

    final sentText = new Container(
      alignment: Alignment.topCenter,
      child: new Text(
        "Email Sent!",
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 14.0,
            fontStyle: FontStyle.normal,
            color: Colors.green
        ),
      ),
    );

    final sendButton = new SizedBox(
      width: double.infinity,
      height: 45.0,
      child: hideSendButton
          ? null
          : new RaisedButton(
        onPressed: () {
          _continueAction();
        },
        textColor: Colors.white,
        color: kColorBlue,
        child: new Text("Send It"),
      ),
    );

    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: kColorOffWhite,
      ),
      backgroundColor: kColorOffWhite,
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
                  ResetText,
                  SizedBox(height: 30.0),
                  emailRow,
                  SizedBox(height: 25.0),
                  showSentText ? sentText : SizedBox(),
                  errorText,
                ].toList(),
              ),
            ),
            sendButton
          ],
        ),
      ),
    );
  }

  _checkForCompletion() {
    if (emailInput.text.contains("@") && emailInput.text.contains(".")) {
      if (this.mounted) setState(() {
        hideSendButton = false;
      });
    } else {
      if (this.mounted) setState(() {
        hideSendButton = true;
      });
    }
  }

  _continueAction() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var succeed = true;

    if (this.mounted) setState(() {
      inputErrorText = "";
      showSentText = false;
    });

    _auth.sendPasswordResetEmail(email: emailInput.text).catchError((error) {
      int errorLength = error.toString().length;
      String errorToString = error.toString().substring(50, errorLength - 1);

      if (this.mounted) setState(() {
        inputErrorText = errorToString;
      });

      succeed = false;
    }).whenComplete(() {
      if (succeed == true) {
        if (this.mounted) setState(() {
          showSentText = true;
          hideSendButton = true;
        });
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
  }

}
