import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/utils/reusable_registration_textfield.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CreateDisplayName extends StatefulWidget {
  @override
  _CreateDisplayNameState createState() => _CreateDisplayNameState();
}

class _CreateDisplayNameState extends State<CreateDisplayName> {
  String displayName;
  bool _isButtonDisabled = true;
  bool showSpinner = false;
  int red;
  int green;
  int blue;

  @override
  void initState() {
    super.initState();
    createRandomColor();
  }

  createRandomColor() {
    Random rnd;
    int min = 1;
    int max = 255;
    int bMax = 188;
    rnd = new Random();
    final r = min + rnd.nextInt(max - min);
    final g = min + rnd.nextInt(max - min);
    final b = min + rnd.nextInt(bMax - min);

    setState(() {
      red = r;
      green = g;
      blue = b;
    });
  }

  isValid() {
    if (displayName.isNotEmpty && displayName.length > 2) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }

    if (displayName.contains(' ')) {
      setState(() {
        _isButtonDisabled = true;
      });
      kErrorFlushbar(context: context, errorText: 'Username cannot contain spaces');
    }
  }

  _isNameAvailable() {
    final ref = Firestore.instance.collection('users');
    ref.getDocuments().then((snapshot) {
      snapshot.documents.forEach((doc) {
        final username = doc.data['displayName'];
        if (displayName == username) {
          setState(() {
            _isButtonDisabled = true;
          });
          kErrorFlushbar(context: context, errorText: '$displayName already taken');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            height: screenHeight / 2.2,
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
                                    currentUser.displayName == null ? 'Choose a Username' : 'Change Username',
                                    textAlign: TextAlign.center,
                                    style: kRegistrationPurpleTextStyle,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      ReusableRegistrationTextField(
                                        hintText: currentUser.displayName == null ? 'Your username' : currentUser.displayName,
                                        maxLength: 16,
                                        keyboardType:
                                        TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        icon: FontAwesomeIcons.at,
                                        color: Color.fromRGBO(red, green, blue, 1.0),
                                        onSubmitted: (v) {
                                          _isButtonDisabled ? print('not good') : handleAddDisplayName();
                                        },
                                        onChanged: (value) {
                                          displayName = value;
                                          _isNameAvailable();
                                          isValid();
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                      RaisedButton(
                                        color: kColorDarkThistle,
                                        onPressed: () => createRandomColor(),
                                        child: Text(
                                          'Randomize Display Color',
                                          style: kDefaultTextStyle.copyWith(color: Colors.white),
                                        ),
                                        splashColor: Colors.grey[200],
                                        highlightColor: Colors.transparent,
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: FlatButton.icon(
                                          onPressed: () => _isButtonDisabled ? print('not good') : handleAddDisplayName(),
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
                                                : 'Done',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleAddDisplayName() {
    setState(() {
      showSpinner = true;
    });
    usersRef.document(currentUser.uid).updateData({
      'displayName': displayName,
      'red': red,
      'green': green,
      'blue': blue,
    }).whenComplete(() {
      setState(() {
        showSpinner = false;
      });
      Navigator.pop(context);
    });
  }
}
