import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  bool _isButtonDisabled;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _forgotPasswordFocus = FocusNode();

  String forgotPasswordEmail;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = true;
  }

  void isTextFieldValid() {
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          "Welcome Back",
          textAlign: TextAlign.left,
          style: kAppBarTextStyle.copyWith(
            color: kColorPurple,
          ),
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: Colors.grey[200],
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorPurple),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanDown: (_) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      TextField(
                        cursorColor: kColorPurple,
                        onChanged: (value) {
                          email = value;
                          isTextFieldValid();
                        },
                        focusNode: null,
                        onSubmitted: (v) {
                          FocusScope.of(context)
                              .requestFocus(_emailFocus);
                        },
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        style: kDefaultTextStyle,
                        decoration: kRegistrationInputDecoration.copyWith(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          hintStyle: kDefaultTextStyle.copyWith(
                            color: kColorLightGray,
                          ),
                          labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          icon: Icon(
                            FontAwesomeIcons.envelope,
                            color: kColorBlack71,
                            size: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        obscureText: true,
                        cursorColor: kColorPurple,
                        onChanged: (value) {
                          password = value;
                          isTextFieldValid();
                        },
                        focusNode: _emailFocus,
                        onSubmitted: (v) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocus);
                          _logIn();
                        },
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        style: kDefaultTextStyle,
                        decoration: kRegistrationInputDecoration.copyWith(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          hintStyle: kDefaultTextStyle.copyWith(
                            color: kColorLightGray,
                          ),
                          labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                          icon: Icon(
                            FontAwesomeIcons.lockOpen,
                            color: kColorBlack71,
                            size: 20.0,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: FlatButton(
                          onPressed: () {
                            Alert(
                              context: context,
                              title: 'Password Reset Link',
                              style: AlertStyle(
                                backgroundColor: kColorOffWhite,
                                overlayColor:
                                Colors.black.withOpacity(0.75),
                                titleStyle: kDefaultTextStyle.copyWith(
                                  color: kColorBlack71,
                                  fontSize: 24.0,
                                ),
                                descStyle: kDefaultTextStyle.copyWith(
                                  color: kColorBlack71,
                                  fontSize: 16.0,
                                ),
                              ),
                              content: TextField(
                                onChanged: (value) {
                                  forgotPasswordEmail = value;
                                },
                                onSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(
                                      _forgotPasswordFocus);
                                  forgotPassword();
                                },
                                autocorrect: false,
                                keyboardType:
                                TextInputType.emailAddress,
                                textInputAction: TextInputAction.send,
                                autofocus: true,
                                style: kDefaultTextStyle,
                                cursorColor: kColorPurple,
                                decoration:
                                kRegistrationInputDecoration
                                    .copyWith(
                                  labelText: 'Email',
                                  labelStyle:
                                  kDefaultTextStyle.copyWith(
                                    color: kColorLightGray,
                                  ),
                                  icon: Icon(
                                    FontAwesomeIcons.at,
                                    color: kColorBlack71,
                                  ),
                                ),
                              ),
                              buttons: [
                                DialogButton(
                                  onPressed: () => forgotPassword(),
                                  child: Text('Send It',
                                      style: kDefaultTextStyle.copyWith(
                                        color: Colors.white,
                                      )),
                                  color: kColorBlue,
                                ),
                              ],
                            ).show();
                          },
                          splashColor: kColorOffWhite,
                          highlightColor: Colors.transparent,
                          child: Text(
                            'Forgot Password?',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: kColorBlue,
                              fontFamily: 'Arimo',
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: FlatButton.icon(
                          onPressed: _logIn,
                          splashColor: _isButtonDisabled
                              ? Colors.transparent
                              : kColorOffWhite,
                          highlightColor: Colors.transparent,
                          icon: Icon(
                            _isButtonDisabled
                                ? FontAwesomeIcons.arrowAltCircleUp
                                : FontAwesomeIcons
                                .arrowAltCircleRight,
                            size: 30.0,
                            color: _isButtonDisabled
                                ? kColorLightGray
                                : kColorPurple,
                          ),
                          label: Text(
                            _isButtonDisabled ? 'Not Done' : 'Log In',
                            style: kDefaultTextStyle.copyWith(
                                color: _isButtonDisabled
                                    ? kColorLightGray
                                    : kColorPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void forgotPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: forgotPasswordEmail);
      Navigator.pop(context);
      kShowAlert(
        context: context,
        title: 'Email Sent',
        desc: 'Check the link sent to $forgotPasswordEmail',
        buttonText: 'Ok',
        onPressed: () => Navigator.pop(context),
        color: kColorBlue,
      );
    } catch (e) {
      kShowAlert(
        context: context,
        title: 'Uh oh',
        desc: 'Unable to send link to $forgotPasswordEmail',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
        color: kColorRed,
      );
    }
  }

  _logIn() async {
    if (_isButtonDisabled) {
      return;
    } else {
      setState(() {
        showSpinner = true;
      });
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          _saveUserSharedPref();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
                  (Route<dynamic> route) => false);
        }
        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          showSpinner = false;
        });
        kShowAlert(
          context: context,
          title: 'Sign Up Failed',
          desc:
          'Email example: your_email@mail.com\nPassword must contain at least 6 characters',
          buttonText: 'Try Again',
          onPressed: () => Navigator.pop(context),
          color: kColorRed
        );
      }
    }
  }

  _saveUserSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    DocumentSnapshot doc = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get();

    User currentUser = User.fromDocument(doc);
    await prefs.setString('username', currentUser.username);
    await prefs.setString('profileImageUrl', currentUser.profileImageUrl);
    await prefs.setString('uid', currentUser.uid);
    await prefs.setBool('hideMe', false);
  }
}
