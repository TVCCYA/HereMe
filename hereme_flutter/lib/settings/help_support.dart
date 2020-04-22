import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/home/bottom_bar.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/registration/initial_page.dart';
import 'package:hereme_flutter/settings/blocked_profiles.dart';
import 'package:hereme_flutter/utils/settings_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
          icon: Icon(FontAwesomeIcons.chevronLeft, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kColorBlack62,
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
          label: 'Reset Password',
          color: kColorBlue.withOpacity(0.7),
          onTap: () => showResetPasswordAlert(context),
        ),
        InkWell(
          onTap: () => !isAdmin ? _resetWeeklyViews() : _deleteAlert(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: kColorBlue.withOpacity(0.7),
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

  addCreationDate() {
    followersRef.getDocuments().then((snapshot) {
      snapshot.documents.forEach((doc) {
        if (doc.exists) {
          final ref = followersRef.document(doc.documentID).collection('users');
          ref.getDocuments().then((snaps) {
            snaps.documents.forEach((docu) {
              if (docu.exists) {
                ref.document(docu.documentID).setData({'creationDate': 0}, merge: true);
              }
            });
          });
        }
      });
    });
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
    final activityFeed = activityRef.document(uid);
    final latestPost = liveChatsRef.document(uid);

    _storage.ref().child('profile_images/$uid').delete().whenComplete(() {
      _storage.ref().child('recent_upload_thumbnail/$uid').delete();
      userReference.delete();
      userLocation.delete();

      _handleRemoveCollection(socialMedias, 'socials');
      _handleRemoveCollection(activityFeed, 'feedItems');
      _handleRemoveCollection(knocks, 'receivedKnockFrom');
      _handleRemoveCollection(latestPost, 'posts');
      kDeleteSentKnocks(uid);

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
