import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:hereme_flutter/nav_controller_state.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:hereme_flutter/utils/reusable_registration_textfield.dart';
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
    //removes status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bubbly2.png"),
            fit: BoxFit.none,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                        FontAwesomeIcons.chevronLeft,
                        size: 25.0,
                        color: Colors.white,
                      ),
                  ),
                ),
              ),
              ModalProgressHUD(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: screenHeight / 2.35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[800],
                                blurRadius:
                                    5.0, // has the effect of softening the shadow
                                spreadRadius:
                                    2.0, // has the effect of extending the shadow
                                offset: Offset(
                                  8.0, // horizontal, move right 10
                                  8.0, // vertical, move down 10
                                ),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  'Welcome Back',
                                  textAlign: TextAlign.center,
                                  style: kRegistrationPurpleTextStyle,
                                ),
                                Column(
                                  children: <Widget>[
                                    ReusableRegistrationTextField(
                                      hintText: 'Enter your email',
                                      focusNode: null,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      icon: FontAwesomeIcons.at,
                                      onSubmitted: (v) {
                                        FocusScope.of(context)
                                            .requestFocus(_emailFocus);
                                      },
                                      onChanged: (value) {
                                        email = value;
                                        isTextFieldValid();
                                      },
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    ReusableRegistrationTextField(
                                      hintText: 'Enter your password',
                                      obscureText: true,
                                      focusNode: _emailFocus,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      icon: FontAwesomeIcons.lockOpen,
                                      onSubmitted: (v) {
                                        FocusScope.of(context)
                                            .requestFocus(_passwordFocus);
                                        _logIn();
                                      },
                                      onChanged: (value) {
                                        password = value;
                                        isTextFieldValid();
                                      },
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
                                                color: kColorBlack105,
                                                fontSize: 24.0,
                                              ),
                                              descStyle: kDefaultTextStyle.copyWith(
                                                color: kColorBlack105,
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
                                                  color: kColorBlack105,
                                                ),
                                              ),
                                            ),
                                            buttons: [
                                              DialogButton(
                                                onPressed: forgotPassword,
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
                                            fontFamily: 'Montserrat',
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void forgotPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: forgotPasswordEmail);
      Navigator.pop(context);
      kShowFlushBar(
          text: 'Check the link sent to $forgotPasswordEmail',
          icon: FontAwesomeIcons.check,
          color: kColorGreen,
          context: context);
    } catch (e) {
      kShowFlushBar(
          text: 'Unable to send link to $forgotPasswordEmail',
          icon: FontAwesomeIcons.times,
          color: kColorRed,
          context: context);
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Home()));
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
  }
}
