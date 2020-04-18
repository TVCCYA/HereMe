import 'dart:math';
import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CreateDisplayName extends StatefulWidget {
  final bool showBackButton;
  CreateDisplayName({this.showBackButton = true});

  @override
  _CreateDisplayNameState createState() => _CreateDisplayNameState(
      showBackButton: this.showBackButton
  );
}

class _CreateDisplayNameState extends State<CreateDisplayName> {
  final bool showBackButton;
  _CreateDisplayNameState({this.showBackButton = true});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String displayName;
  bool _isButtonDisabled = true;
  bool _isAvailable = false;
  bool showSpinner = false;
  int red = 0;
  int green = 0;
  int blue = 0;

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
    else if (displayName.length < 3) {
      kShowSnackbar(
          key: _scaffoldKey,
          text: 'Username must be 3 characters or more',
          backgroundColor: kColorRed
      );
    }
    else if (_isAvailable) {
      kShowSnackbar(
          key: _scaffoldKey,
          text: '$displayName already taken',
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
          showBackButton ? 'Username' : 'Create Username',
          textAlign: TextAlign.left,
          style: kAppBarTextStyle
        ),
        leading: showBackButton ? IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack71,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ) : SizedBox(),
        actions: <Widget>[
          Center(
              child: FlatButton(
                child: Text(
                  'Done',
                  style: kAppBarTextStyle.copyWith(color: _isButtonDisabled ? kColorLightGray : kColorBlue),
                ),
                onPressed: () => _isButtonDisabled ? _onSubmitErrors() : handleAddDisplayName(),
                splashColor: kColorExtraLightGray,
                highlightColor: Colors.transparent,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: circularProgress(),
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
                    cursorColor: kColorLightGray,
                    onChanged: (value) {
                      displayName = value;
                      _isNameAvailable();
                      _isValid();
                    },
                    focusNode: null,
                    onSubmitted: (v) {
                      _isButtonDisabled
                          ? _onSubmitErrors()
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
                    splashColor: kColorExtraLightGray,
                    highlightColor: Colors.transparent,
                  ),
                ],
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

    Map<String, dynamic> data = <String, dynamic>{
      'displayName': displayName,
      'red': red,
      'green': green,
      'blue': blue,
    };

    final ref = usersRef.document(currentUser.uid);
    ref.updateData(data).whenComplete(() {
      ref.collection('updatedFields').document('displayName').setData({
        'displayName': displayName,
      }).whenComplete(() {
        updateCurrentUserInfo();
        if (this.mounted) setState(() {
          showSpinner = false;
        });
      });
      kShowSnackbar(
        key: _scaffoldKey,
        text: 'Successfully changed username to $displayName',
        backgroundColor: kColorGreen,
      );
      Future.delayed(Duration(seconds: 2), () => showBackButton ? Navigator.pop(context) :
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) => BottomBar()),
              (Route<dynamic> route) => false));
    });
  }

  updateCurrentUserInfo() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);
  }
}
