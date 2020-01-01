import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/home.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/settings/blocked_profiles.dart';
import 'package:hereme_flutter/utils/settings_tile.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameChangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
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
          splashColor: kColorExtraLightGray,
          highlightColor: Colors.transparent,
        ),
      ),
      body: Column(children: <Widget>[
        SettingsTile(
          label: 'Blocked Profiles',
          color: kColorBlue.withOpacity(1.0),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => BlockedProfiles())),
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
          onTap: () => _nameChangeAlert(context),
        ),
        SettingsTile(
          label: 'Reset Password',
          color: kColorBlue.withOpacity(0.6),
          onTap: () => showResetPasswordAlert(context),
        ),
        InkWell(
          onTap: () => isAdmin ? _resetWeeklyViews() : _deleteAlert(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: kColorBlue.withOpacity(0.6),
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: Center(
                  child: Text(
                    isAdmin ? 'Reset Weekly Views' : 'Delete HereMe Account',
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

  _resetWeeklyViews() {
    usersRef.getDocuments().then((snapshot) {
      snapshot.documents.forEach((doc) {
        if (doc.exists) {
          final uid = doc.data['uid'];
          usersRef.document(uid).updateData({
            'weeklyVisitsCount': 0,
          });
        }
      });
    }).whenComplete(() {
      kShowSnackbar(
        key: _scaffoldKey,
        text: 'Good work there bud',
        backgroundColor: kColorGreen,
      );
    });
  }

  _nameChangeAlert(BuildContext context) async {
    Alert(
        context: context,
        title: 'Change Name',
        style: AlertStyle(
          backgroundColor: kColorOffWhite,
          overlayColor: Colors.black.withOpacity(0.75),
          titleStyle: kDefaultTextStyle.copyWith(
            color: kColorBlack71,
            fontSize: 24.0,
          ),
          descStyle: kDefaultTextStyle.copyWith(
            color: kColorBlack71,
            fontSize: 16.0,
          ),
        ),
        content: Column(
          children: <Widget>[
            TextField(
              controller: _nameChangeController,
              style: kDefaultTextStyle,
              onSubmitted: (v) => _submitUpdateNameChange(context),
              cursorColor: kColorLightGray,
              decoration: kRegistrationInputDecoration.copyWith(
                labelText: 'First Name',
                labelStyle: kDefaultTextStyle.copyWith(
                  color: kColorLightGray,
                ),
                icon: Icon(
                  FontAwesomeIcons.signature,
                  color: kColorBlack71,
                ),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => _submitUpdateNameChange(context),
            child: Text(
              'Update',
              style: kDefaultTextStyle.copyWith(color: Colors.white),
            ),
            color: kColorBlue,
          )
        ]).show();
  }

  _submitUpdateNameChange(context) {
    _nameChangeController.text.length > 0
        ? _handleNameChange(context)
        : kShowSnackbar(
            key: _scaffoldKey,
            text: 'Name cannot be empty',
            backgroundColor: kColorRed);
  }

  _handleNameChange(BuildContext context) async {
    final userReference = usersRef.document(currentUser.uid);
    Map<String, String> nameData = <String, String>{
      'username': _nameChangeController.text,
    };
    userReference.updateData(nameData).whenComplete(() {
      _updatePreferences(context);
      kShowSnackbar(
        key: _scaffoldKey,
        text: 'Successfully changed name',
        backgroundColor: kColorGreen,
      );
    }).catchError((e) => print(e));
  }

  _updatePreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .setString('username', _nameChangeController.text)
        .whenComplete(() {
      Navigator.pop(context);
    });
  }

  showResetPasswordAlert(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    String email = user.email;
    kShowAlertMultiButtons(
        context: context,
        title: 'Send Email?',
        desc:
            'We will email you a link to your HereMe email account ($email) for you to change your password',
        buttonText1: 'Send It',
        color1: kColorGreen,
        buttonText2: 'Cancel',
        color2: kColorLightGray,
        onPressed1: () => _forgotPassword(context, email),
        onPressed2: () => Navigator.pop(context));
  }

  _forgotPassword(BuildContext context, String email) async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      kShowAlert(
        context: context,
        title: 'Email Sent',
        desc: 'Check the link sent to $email',
        buttonText: 'Ok',
        onPressed: () => Navigator.pop(context),
        color: kColorBlue,
      );
    } catch (e) {
      kShowAlert(
        context: context,
        title: 'Uh oh',
        desc: 'Unable to send link to $email',
        buttonText: 'Try Again',
        onPressed: () => Navigator.pop(context),
        color: kColorRed,
      );
    }
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

  _deleteAlert(BuildContext context) async {
    kShowAlertMultiButtons(
        context: context,
        title: 'Delete Account?',
        desc:
            'Are you sure you want to delete everything you have done on HereMe?',
        color1: kColorRed,
        color2: kColorLightGray,
        buttonText1: 'Delete',
        buttonText2: 'Cancel',
        onPressed1: () => _handleAccountDelete(context),
        onPressed2: () => Navigator.pop(context));
  }

  _handleRemoveCollection(DocumentReference ref, String collection) {
    ref.collection(collection).snapshots().forEach((snapshot) {
      snapshot.documents.forEach((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  _retrieveAndDeleteLiveChat(String uid) {
    liveChatsRef
        .document(uid)
        .collection('chats')
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((doc) {
        if (doc.exists) {
          final chatId = doc.data['chatId'];
          _handleRemoveCollection(usersInChatRef.document(chatId), 'invited');
          _handleRemoveCollection(usersInChatRef.document(chatId), 'inChat');
          _handleRemoveCollection(
              liveChatMessagesRef.document(chatId), 'messages');
          liveChatLocationsRef.document(chatId).delete();
        }
      });
    });
  }

  _handleAccountDelete(BuildContext context) async {
    String uid = currentUser.uid;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userReference = usersRef.document(uid);
    final userLocation = userLocationsRef.document(uid);

    final socialMedias = socialMediasRef.document(uid);
    final knocks = knocksRef.document(uid);
    final recentUploads = recentUploadsRef.document(uid);
    final activityFeed = activityRef.document(uid);
    final liveChats = liveChatsRef.document(uid);

    _storage.ref().child('profile_images/$uid').delete().whenComplete(() {
      _storage.ref().child('recent_upload_thumbnail/$uid').delete();
      userReference.delete();
      userLocation.delete();

      _handleRemoveCollection(socialMedias, 'socials');
      _handleRemoveCollection(activityFeed, 'feedItems');
      _handleRemoveCollection(knocks, 'receivedKnockFrom');
      _handleRemoveCollection(recentUploads, 'recents');
      kDeleteSentKnocks(uid);
      _retrieveAndDeleteLiveChat(uid);
      _handleRemoveCollection(liveChats, 'chats');

      user.delete().whenComplete(() {
        print('all deleted');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => InitialPage()),
            (Route<dynamic> route) => false);
      });
    });
  }
}
