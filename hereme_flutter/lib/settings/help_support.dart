import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/GridFind/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/settings/blocked_profiles.dart';
import 'package:hereme_flutter/utils/settings_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Help & Support",
          style: kAppBarTextStyle,
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
      body: Column(children: <Widget>[
        SettingsTile(
          label: 'Blocked Profiles',
          color: kColorBlue.withOpacity(1.0),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BlockedProfiles())),
        ),
        SettingsTile(
          label: 'Privacy Policy',
          color: kColorBlue.withOpacity(0.9),
          onTap: () => _openPrivacyPolicy(),
        ),
        SettingsTile(
          label: 'Terms & Conditions',
          color: kColorBlue.withOpacity(0.8),
          onTap: () => _openTermsConditions(),
        ),
        SettingsTile(
          label: 'Change First Name',
          color: kColorBlue.withOpacity(0.7),
          onTap: () => _jankAlert(context),
        ),
        SettingsTile(
          label: 'Reset Password',
          color: kColorBlue.withOpacity(0.6),
          onTap: () => print('pword'),
        ),
        InkWell(
          onTap: () => _deleteAlert(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: kColorBlue.withOpacity(0.6),
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Delete HereMe Account',
                    style: kAppBarTextStyle.copyWith(
                        color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  _jankAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "TextField in Dialog"),
              onSubmitted: (_) {
                if (_textFieldController.text.length > 1) {
                  _handleNameChange(context);
                } else {
                  print(
                      "alert the user their name must be a minimum of 3 characters");
                }
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _openPrivacyPolicy() async {
    String url =
        "https://termsfeed.com/privacy-policy/82297978c6805adec572a51e13a5df2a";

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }

  _openTermsConditions() async {
    String url =
        "https://termsfeed.com/terms-conditions/eb83aa859848185014a8c99fb5fbfadb";

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }

  _handleNameChange(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final userReference = usersRef.document(user.uid);

    Map<String, String> nameData = <String, String>{
      'username': _textFieldController.text,
    };

    userReference.updateData(nameData).whenComplete(() {
      print("Name Changed");
//      _updatePreferences(context);
    }).catchError((e) => print(e));
  }

  _updatePreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _textFieldController.text).whenComplete(() {
      Navigator.pop(context);
    });
  }

  _deleteAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: FlatButton(
              child: new Text('OKAYYY'),
              onPressed: () {
                _handleAccountDelete();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => InitialPage()),
                        (Route<dynamic> route) => false);
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
    );
  }

  _handleAccountDelete() async {
    String uid = currentUser.uid;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userReference = usersRef.document(uid);
    final userLocation = userLocationsRef.document(uid);
    final userAccounts = socialMediasRef.document(uid);
    final currentUsersKnocks = knocksRef.document(uid);
    final recentUploads = recentUploadsRef.document(uid);
    final usersTheyKnocked = knocksRef.where('uid', isEqualTo: uid).snapshots();
    // get live chat id to query then delete
    final liveChatsCreated = liveChatLocationsRef.where('uid', isEqualTo: currentUser.uid).snapshots();

    _storage.ref().child('profile_images/$uid').delete().whenComplete((){
      _storage.ref().child('recent_upload_thumbnail/$uid').delete();
      userReference.delete();
      userLocation.delete();
      userAccounts.delete();
      recentUploads.delete();
      currentUsersKnocks.delete();

      // still need to delete:
      // users messages in live chats
      // users created live chats
      // maybe not tho bc these should eventually just delete automatically

      user.delete().whenComplete(() {

      });
    });
  }
}
