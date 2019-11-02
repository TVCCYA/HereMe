import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/photo_add.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/utils/reusable_registration_textfield.dart';
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
  bool _isButtonDisabled;

  final _firstNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = true;
  }

  void isTextFieldValid() {
    if (email.isNotEmpty && password.isNotEmpty && firstName.isNotEmpty) {
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
      resizeToAvoidBottomInset: false,
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
                child: SafeArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanDown: (_) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: screenHeight / 2,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    'Create an Account',
                                    textAlign: TextAlign.center,
                                    style: kRegistrationPurpleTextStyle,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      ReusableRegistrationTextField(
                                        hintText: 'Enter your email',
                                        focusNode: null,
                                        keyboardType:
                                            TextInputType.emailAddress,
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
                                      SizedBox(height: 8.0),
                                      ReusableRegistrationTextField(
                                        hintText: 'Enter your first name',
                                        focusNode: _emailFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        icon: FontAwesomeIcons.signature,
                                        onSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(_firstNameFocus);
                                        },
                                        onChanged: (value) {
                                          firstName = value;
                                          isTextFieldValid();
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                      ReusableRegistrationTextField(
                                        hintText: 'Enter your password',
                                        obscureText: true,
                                        focusNode: _firstNameFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        icon: FontAwesomeIcons.lock,
                                        onSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(_passwordFocus);
                                          _signUp();
                                        },
                                        onChanged: (value) {
                                          password = value;
                                          isTextFieldValid();
                                        },
                                      ),
                                      SizedBox(height: 8.0),
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
                                                : kColorPurple,
                                          ),
                                          label: Text(
                                            _isButtonDisabled
                                                ? 'Not Done'
                                                : 'Add Photo',
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
                          FlatButton.icon(
                            onPressed: _launchURL,
                            splashColor: kColorBlue,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              FontAwesomeIcons.fileContract,
                              color: kColorOffWhite,
                              size: 16.0,
                            ),
                            label: Text(
                              'Terms & Conditions',
                              style: kDefaultTextStyle.copyWith(
                                  color: kColorOffWhite, fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
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

  _signUp() async {
    if (_isButtonDisabled) {
      return;
    } else {
      setState(() {
        showSpinner = true;
      });
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (newUser != null) {
          _saveUserFirebase();
        }
        setState(() {
          showSpinner = false;
        });
      } catch (e) {
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

  _saveUserFirebase() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.uid;

    final userReference = Firestore.instance.collection('users').document(uid);

    Map<String, dynamic> signUpUserData = <String, dynamic>{
      'username': firstName,
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
        MaterialPageRoute(builder: (context) => new PhotoAdd(uid: uid)),
      );
    }).catchError((e) => print(e));
  }

  _saveUserSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await prefs.setString('username', firstName);
    await prefs.setString('uid', user.uid);
  }

  _launchURL() async {
    const url =
        'https://termsfeed.com/terms-conditions/eb83aa859848185014a8c99fb5fbfadb';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      kShowFlushBar(
        text: 'Whoops, this link cannot be opened',
        icon: FontAwesomeIcons.times,
        color: kColorRed,
        context: context,
      );
    }
  }
}
