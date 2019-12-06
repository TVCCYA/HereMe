import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CreateDisplayName extends StatefulWidget {
  @override
  _CreateDisplayNameState createState() => _CreateDisplayNameState();
}

class _CreateDisplayNameState extends State<CreateDisplayName> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String displayName;
  bool _isButtonDisabled = true;
  bool _isAvailable = false;
  bool showSpinner = false;
  int red;
  int green;
  int blue;

  @override
  void initState() {
    super.initState();
    if (currentUser.red != null) {
      red = currentUser.red;
      green = currentUser.green;
      blue = currentUser.blue;
    } else {
      createRandomColor();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
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

    if (this.mounted) setState(() {
      red = r;
      green = g;
      blue = b;
    });
  }

  _isValid() {
    if (displayName.isNotEmpty && displayName.length > 2) {
      if (this.mounted) setState(() {
        _isButtonDisabled = false;
      });
    } else {
      if (this.mounted) setState(() {
        _isButtonDisabled = true;
      });
    }

    if (displayName.contains(' ')) {
      if (this.mounted) setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  _isNameAvailable() {
    final ref = Firestore.instance.collection('users');
    ref.getDocuments().then((snapshot) {
      snapshot.documents.forEach((doc) {
        final username = doc.data['displayName'];
        if (displayName == username) {
          if (this.mounted) setState(() {
            _isAvailable = false;
            _isButtonDisabled = true;
          });
        } else {
          if (this.mounted) setState(() {
            _isAvailable = true;
          });
        }
      });
    });
  }

  _onSubmitErrors() {
    if (displayName.contains(' ')) {
      kShowSnackbar(
          key: _scaffoldKey,
          text: 'Username cannot contain spaces',
          backgroundColor: kColorRed
      );
    }
    if (!_isAvailable) {
      kShowSnackbar(
          key: _scaffoldKey,
          text: '$displayName already taken',
          backgroundColor: kColorRed
      );
    }
    if (displayName.length < 3) {
      kShowSnackbar(
          key: _scaffoldKey,
          text: 'Username must be 3 characters or more',
          backgroundColor: kColorRed
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          "Change Username",
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
          child: SafeArea(
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
                      maxLength: 16,
                      cursorColor: kColorPurple,
                      onChanged: (value) {
                        displayName = value;
                        _isNameAvailable();
                        _isValid();
                      },
                      focusNode: null,
                      onSubmitted: (v) {
                        _onSubmitErrors();
                        _isButtonDisabled
                            ? print('disabled')
                            : handleAddDisplayName();
                      },
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      style: kDefaultTextStyle.copyWith(
                          color: Color.fromRGBO(red, green, blue, 1.0)),
                      decoration: kRegistrationInputDecoration.copyWith(
                        labelText: 'Username',
                        hintText: currentUser.displayName == null
                            ? 'Your username'
                            : currentUser.displayName,
                        hintStyle: kDefaultTextStyle.copyWith(
                          color: kColorLightGray,
                        ),
                        labelStyle: kAppBarTextStyle.copyWith(
                          fontSize: 16.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.at,
                          color: kColorBlack71,
                          size: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    RaisedButton(
                      color: Color.fromRGBO(red, green, blue, 1.0),
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
                        onPressed: () {
                          _onSubmitErrors();
                          _isButtonDisabled
                              ? print('disabled')
                              : handleAddDisplayName();
                        },
                        splashColor: _isButtonDisabled
                            ? Colors.transparent
                            : kColorOffWhite,
                        highlightColor: Colors.transparent,
                        icon: Icon(
                          _isButtonDisabled
                              ? FontAwesomeIcons.arrowAltCircleUp
                              : FontAwesomeIcons.arrowAltCircleRight,
                          size: 30.0,
                          color: _isButtonDisabled
                              ? kColorLightGray
                              : kColorPurple,
                        ),
                        label: Text(
                          _isButtonDisabled ? 'Not Done' : 'Done',
                          style: kDefaultTextStyle.copyWith(
                              color: _isButtonDisabled
                                  ? kColorLightGray
                                  : kColorPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  handleAddDisplayName() {
    if (this.mounted) setState(() {
      showSpinner = true;
    });
    usersRef.document(currentUser.uid).updateData({
      'displayName': displayName,
      'red': red,
      'green': green,
      'blue': blue,
    }).whenComplete(() {
      if (this.mounted) setState(() {
        showSpinner = false;
      });
      kShowSnackbar(
        key: _scaffoldKey,
        text: 'Successfully changed username to $displayName',
        backgroundColor: kColorGreen,
      );
      Future.delayed(Duration(seconds: 2), () => Navigator.pop(context));
    });
  }
}
