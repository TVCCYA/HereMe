import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/photo_add.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  String firstName;
  String email;
  String password;
  bool _isButtonDisabled = true;
  bool _termsHidden = true;
  bool _agreed = false;

  final _firstNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool showSpinner = false;

  _showTerms() {
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty) {
      if (this.mounted) setState(() {
        _termsHidden = false;
      });
    }
  }

  _isValid() {
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        _agreed == true) {
      if (this.mounted) setState(() {
        _isButtonDisabled = false;
      });
    } else {
      if (this.mounted) setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          "Create Account",
          textAlign: TextAlign.left,
          style: kAppBarTextStyle.copyWith(
            color: kColorRed,
          ),
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorRed),
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
                  TextField(
                    cursorColor: kColorLightGray,
                    onChanged: (value) {
                      email = value;
                      _isValid();
                      _showTerms();
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
                    cursorColor: kColorLightGray,
                    onChanged: (value) {
                      firstName = value;
                      _isValid();
                      _showTerms();
                    },
                    focusNode: _emailFocus,
                    onSubmitted: (v) {
                      FocusScope.of(context)
                          .requestFocus(_firstNameFocus);
                    },
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    style: kDefaultTextStyle,
                    decoration: kRegistrationInputDecoration.copyWith(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      hintStyle: kDefaultTextStyle.copyWith(
                        color: kColorLightGray,
                      ),
                      labelStyle: kAppBarTextStyle.copyWith(fontSize: 16.0),
                      icon: Icon(
                        FontAwesomeIcons.signature,
                        color: kColorBlack71,
                        size: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    obscureText: true,
                    cursorColor: kColorLightGray,
                    onChanged: (value) {
                      password = value;
                      _isValid();
                      _showTerms();
                    },
                    focusNode: _firstNameFocus,
                    onSubmitted: (v) {
                      FocusScope.of(context)
                          .requestFocus(_passwordFocus);
                      _signUp();
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
                        FontAwesomeIcons.lock,
                        color: kColorBlack71,
                        size: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  _termsHidden ? SizedBox() : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        activeColor: kColorRed,
                        value: _agreed,
                        onChanged: (value) {
                          if (this.mounted) setState(() {
                            _agreed = value;
                          });
                          _isValid();
                        },
                      ),
                      FlatButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: _launchURL,
                        splashColor: kColorExtraLightGray,
                        highlightColor: Colors.transparent,
                        child: Text(
                          'Agree to Terms & Conditions',
                          style: kAppBarTextStyle.copyWith(
                              fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: FlatButton.icon(
                      onPressed: _signUp,
                      splashColor: _isButtonDisabled
                          ? Colors.transparent
                          : kColorOffWhite,
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        _isButtonDisabled
                            ? FontAwesomeIcons
                                .arrowAltCircleUp
                            : FontAwesomeIcons
                                .arrowAltCircleRight,
                        size: 30.0,
                        color: _isButtonDisabled
                            ? kColorLightGray
                            : kColorBlue,
                      ),
                      label: Text(
                        _isButtonDisabled
                            ? 'Not Done'
                            : 'Add Photo',
                        style: kDefaultTextStyle.copyWith(
                            color: _isButtonDisabled
                                ? kColorLightGray
                                : kColorBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _signUp() async {
    if (_isButtonDisabled) {
      return;
    } else {
      if (this.mounted) setState(() {
        showSpinner = true;
      });
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (newUser != null) {
          _saveUserFirebase();
        }
        if (this.mounted) setState(() {
          showSpinner = false;
        });
      } catch (e) {
        if (this.mounted) setState(() {
          showSpinner = false;
        });
        kShowAlert(
          context: context,
          title: 'Sign Up Failed',
          desc:
              'Email example: your_email@mail.com\nPassword must contain at least 6 characters',
          buttonText: 'Try Again',
          onPressed: () => Navigator.pop(context),
          color: kColorRed,
        );
      }
    }
  }

  _saveUserFirebase() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.uid;

    final userReference = Firestore.instance.collection('users').document(uid);

    Map<String, dynamic> signUpUserData = <String, dynamic>{
      'username': firstName.trim(),
      'uid': uid,
      'weeklyVisitsCount': 0,
      'totalVisitsCount': 0,
      'hasAccountLinked': false,
    };

    userReference.setData(signUpUserData).whenComplete(() {
      print('User Added');
      _saveUserSharedPref();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhotoAdd(uid: uid)),
      );
    }).catchError((e) => print(e));
  }

  _saveUserSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await prefs.setString('username', firstName.trim());
    await prefs.setString('uid', user.uid);
    await prefs.setBool('hideMe', false);
  }

  _launchURL() async {
    const url =
        'https://termsfeed.com/terms-conditions/eb83aa859848185014a8c99fb5fbfadb';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      kShowAlert(
        context: context,
        title: 'Whoops',
        desc: 'This link cannot be opened at this time',
        buttonText: 'Try Again',
        onPressed: Navigator.pop(context),
        color: kColorRed,
      );
    }
  }
}
