import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class EditBio extends StatefulWidget {
  @override
  _EditBioState createState() => _EditBioState();
}

class _EditBioState extends State<EditBio> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String bio;
  bool _isButtonDisabled = true;
  bool showSpinner = false;

  _isValid() {
    if (bio != null && bio.isNotEmpty && bio.trim().length != 0) {
      if (this.mounted)
        setState(() {
          _isButtonDisabled = false;
        });
    } else {
      if (this.mounted)
        setState(() {
          _isButtonDisabled = true;
        });
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
        title: Text('Bio', textAlign: TextAlign.left, style: kAppBarTextStyle),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack62,
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
        actions: <Widget>[
          _isButtonDisabled
              ? SizedBox()
              : Animator(
                  duration: Duration(milliseconds: 200),
                  tween: Tween(begin: 0.8, end: 1.0),
                  curve: Curves.easeInOutQuad,
                  cycles: 1,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Center(
                      child: FlatButton(
                        child: Text(
                          'Done',
                          style: kAppBarTextStyle.copyWith(color: kColorBlue),
                        ),
                        onPressed: () => handleAddBio(),
                        splashColor: kColorExtraLightGray,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ),
                )
        ],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: circularProgress(),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  maxLines: 5,
                  cursorColor: kColorLightGray,
                  onChanged: (value) {
                    bio = value;
                    _isValid();
                  },
                  onSubmitted: (v) {
                    _isButtonDisabled ? print('nope') : handleAddBio();
                  },
                  focusNode: null,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  style: kDefaultTextStyle,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: currentUser.bio != '' ? currentUser.bio : 'Share something about yourself...',
                    hintStyle: kDefaultTextStyle.copyWith(
                      color: kColorLightGray,
                    ),
                    labelStyle: kAppBarTextStyle.copyWith(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  handleAddBio() {
    if (this.mounted) setState(() {
      showSpinner = true;
    });

    Map<String, dynamic> data = <String, dynamic>{
      'bio': bio,
    };

    final ref = usersRef.document(currentUser.uid);
    ref.updateData(data).whenComplete(() {
        updateCurrentUserInfo();
      });
      Future.delayed(Duration(seconds: 2), () {
      if (this.mounted) setState(() {
        showSpinner = false;
      });
      Navigator.pop(context);
    });
  }

  updateCurrentUserInfo() async {
    final user = await auth.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);
  }
}
