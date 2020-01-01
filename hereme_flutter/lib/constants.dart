import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/home.dart';
const kColorRed = Color.fromRGBO(201, 62, 62, 1.0);
const kColorBlue = Color.fromRGBO(91, 117, 212, 1.0);
const kColorGreen = Color.fromRGBO(62, 201, 62, 1.0);

const kColorBlack71 = Color.fromRGBO(47, 47, 46, 1.0);
const kColorOffWhite = Color.fromRGBO(245, 245, 245, 1.0);
const kColorOffBlack = Color.fromRGBO(11, 8, 19, 1.0);
const kColorLightGray = Color.fromRGBO(171, 171, 171, 1.0);
const kColorExtraLightGray = Color.fromRGBO(234, 234, 234, 1.0);
const kColorThistle = Color.fromRGBO(228, 162, 162, 1.0);
const kColorDarkThistle = Color.fromRGBO(215, 115, 115, 1.0);
const kColorDarkRed = Color.fromRGBO(120, 37, 37, 1.0);
const kColorDarkBlue = Color.fromRGBO(63, 81, 148, 1.0);
// SOCIAL MEDIA COLORS
const kColorInstagram = Color.fromRGBO(185, 0, 180, 1.0);
const kColorSnapchat = Color.fromRGBO(255, 252, 0, 1.0);
const kColorTwitter = Color.fromRGBO(29, 161, 242, 1.0);
const kColorFacebook = Color.fromRGBO(21, 120, 242, 1.0);
const kColorYoutube = Color.fromRGBO(255, 0, 0, 1.0);
const kColorSoundcloud = Color.fromRGBO(255, 136, 0, 1.0);
const kColorPinterest = Color.fromRGBO(230, 0, 35, 1.0);
const kColorSpotify = Color.fromRGBO(30, 215, 96, 1.0);
const kColorVenmo = Color.fromRGBO(61, 149, 206, 1.0);
const kColorTumblr = Color.fromRGBO(53, 70, 92, 1.0);
const kColorReddit = Color.fromRGBO(255, 69, 0, 1.0);
const kColorLinkedIn = Color.fromRGBO(0, 119, 181, 1.0);
const kColorTwitch = Color.fromRGBO(145, 70, 255, 1.0);
const kColorTikTok = Color.fromRGBO(0, 242, 234, 1.0);

ThemeData kTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    accentColor: kColorBlack71,
    unselectedWidgetColor: kColorLightGray,
    dividerColor: kColorExtraLightGray,
    highlightColor: Colors.transparent,
    splashColor: kColorExtraLightGray,
  );
}

const kAppBarTextStyle = TextStyle(
  fontFamily: 'Avenir',
  fontSize: 18.0,
  color: kColorBlack71,
  fontWeight: FontWeight.w800,
);

const kDefaultTextStyle = TextStyle(
  color: kColorBlack71,
  fontFamily: 'Avenir',
  fontWeight: FontWeight.w400,
  fontSize: 16.0,
);

const kRegistrationInputDecoration = InputDecoration(
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kColorLightGray,
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: kColorLightGray),
  ),
);

void kShowFlushBar(
    {text: String, icon: IconData, color: Color, context: BuildContext}) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.white,
    messageText: Text(
      text,
      style: kDefaultTextStyle,
    ),
    icon: Icon(
      icon,
      size: 28.0,
      color: color,
    ),
    duration: Duration(seconds: 3),
    leftBarIndicatorColor: color,
  )..show(context);
}

void kErrorFlushbar({BuildContext context, String errorText}) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.white,
    messageText: Text(
      errorText,
      style: kDefaultTextStyle,
    ),
    icon: Icon(
      FontAwesomeIcons.exclamation,
      size: 28.0,
      color: kColorRed,
    ),
    duration: Duration(seconds: 3),
    leftBarIndicatorColor: kColorRed,
  )..show(context);
}

void kShowAlert({
  context: BuildContext,
  title: String,
  desc: String,
  buttonText: String,
  onPressed: Function,
  color: Color,
}) {
  kSelectionClick();
  Alert(
    context: context,
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
    type: null,
    title: title,
    desc: desc,
    buttons: [
      DialogButton(
        child: Text(
          buttonText,
          style: kDefaultTextStyle.copyWith(
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
        color: color,
        radius: BorderRadius.circular(5.0),
      ),
    ],
  ).show();
}

void kShowAlertMultiButtons(
    {context: BuildContext,
    title: String,
    desc: String,
    color1: Color,
    color2: Color,
    buttonText1: String,
    buttonText2: String,
    onPressed1: Function,
    onPressed2: Function}) {
  kSelectionClick();
  Alert(
    context: context,
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
    type: null,
    title: title,
    desc: desc,
    buttons: [
      DialogButton(
        child: Text(
          buttonText1,
          style: kDefaultTextStyle.copyWith(
            color: Colors.white,
          ),
        ),
        onPressed: onPressed1,
        color: color1,
        radius: BorderRadius.circular(5.0),
      ),
      DialogButton(
        child: Text(
          buttonText2,
          style: kDefaultTextStyle.copyWith(
            color: Colors.white,
          ),
        ),
        onPressed: onPressed2,
        color: color2,
        radius: BorderRadius.circular(5.0),
      ),
    ],
  ).show();
}

void kActionSheet(context, sheets) {
  kSelectionClick();
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: sheets,
          ),
        ),
      );
    },
  );
}

const kRegistrationPurpleTextStyle = TextStyle(
  color: kColorRed,
  fontSize: 32.0,
  fontFamily: 'Berlin-Sans',
);

String kIconPath(String socialMedia) {
  switch (socialMedia) {
    case 'twitterUsername':
      {
        return 'images/SocialMedias/twitter120.png';
      }
      break;
    case 'snapchatUsername':
      {
        return 'images/SocialMedias/snapchat120.png';
      }
      break;
    case 'instagramUsername':
      {
        return 'images/SocialMedias/instagram120.png';
      }
      break;
    case 'youtubeUsername':
      {
        return 'images/SocialMedias/youtube120.png';
      }
      break;
    case 'soundcloudUsername':
      {
        return 'images/SocialMedias/soundcloud120.png';
      }
      break;
    case 'venmoUsername':
      {
        return 'images/SocialMedias/venmo120.png';
      }
      break;
    case 'spotifyUsername':
      {
        return 'images/SocialMedias/spotify120.png';
      }
      break;
    case 'twitchUsername':
      {
        return 'images/SocialMedias/twitch120.png';
      }
      break;
    case 'tumblrUsername':
      {
        return 'images/SocialMedias/tumblr120.png';
      }
      break;
    case 'redditUsername':
      {
        return 'images/SocialMedias/reddit120.png';
      }
      break;
    case 'facebookUsername':
      {
        return 'images/SocialMedias/facebook120.png';
      }
      break;
    case 'your websiteUsername':
      {
        return 'images/SocialMedias/website.png';
      }
    case 'tiktokUsername':
      {
        return 'images/SocialMedias/tiktok120.png';
      }
    case 'pinterestUsername':
      {
        return 'images/SocialMedias/pinterest120.png';
      }
    default:
      {
        return "couldn't find social media username to link";
      }
  }
}

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kColorRed),
      backgroundColor: kColorLightGray,
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.all(10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kColorRed),
      backgroundColor: kColorLightGray,
    ),
  );
}

void kConfirmBlock(BuildContext context, String displayName, String uid) {
  Navigator.pop(context);
  kShowAlert(
    context: context,
    title: 'Block $displayName?',
    desc:
        'They will not be able to see your content on HereMe. They will not know you blocked them.',
    buttonText: 'Block',
    onPressed: () {
      kBlockUser(context, uid, displayName);
      Navigator.pop(context);
    },
    color: kColorRed,
  );
}

void kBlockUser(BuildContext context, String uid, String displayName) {
  usersRef.document(currentUser.uid).updateData({
    'blockedUsers.$uid': 1,
  }).whenComplete(() {
    usersRef.document(uid).updateData({
      'blockedUsers.${currentUser.uid}': 0,
    }).whenComplete(() {
      kShowAlert(
        context: context,
        title: '$displayName Blocked',
        desc: 'You can unblock them through your profile settings',
        buttonText: 'Dismiss',
        onPressed: () {
          Navigator.pop(context);
        },
        color: kColorBlue,
      );
    });
  });
}

void kRemoveLiveChatMessages(String chatId) {
  final ref = liveChatMessagesRef.document(chatId).collection('messages');
  ref.getDocuments().then((snapshot) {
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        final messageId = doc.data['messageId'];
        ref.document(messageId).delete();
      }
    });
  });
}

void kDeleteSentKnocks(String currentUserUid) {
  final ref = knocksRef.document(currentUserUid).collection('sentKnockTo');
  ref.getDocuments().then((snapshot) {
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        final uid = doc.data['uid'];
        knocksRef.document(uid).collection('receivedKnockFrom').document(currentUserUid).get().then((document) {
          if (document.exists) {
            document.reference.delete().whenComplete(() {
              doc.reference.delete();
            });
          }
        });
      }
    });
  });
}

void kHandleRemoveDataAtId(
    String id, String uid, String collection1, String collection2) async {
  final ref = Firestore.instance
      .collection(collection1)
      .document(uid)
      .collection(collection2);

  ref.getDocuments().then((snapshot) {
    for (final doc in snapshot.documents) {
      if (doc.exists) {
        if (doc.data.containsValue(id)) {
          ref.document(id).delete();
        }
      }
    }
  });
}

String kTimeRemaining(int duration) {
  String result;
  if (duration <= 1800000) {
    result = '< 30 mins left';
  } else if (duration <= 3600000) {
    result = '< 1 hour left';
  } else if (duration <= 7200000) {
    result = '< 2 hours left';
  } else if (duration <= 10800000) {
    result = '< 3 hours left';
  } else if (duration <= 14400000) {
    result = '< 4 hours left';
  } else if (duration <= 18000000) {
    result = '< 5 hours left';
  } else if (duration <= 21600000) {
    result = '< 6 hours left';
  } else if (duration <= 25200000) {
    result = '< 7 hours left';
  } else if (duration <= 28800000) {
    result = '< 8 hours left';
  } else if (duration <= 32400000) {
    result = '< 9 hours left';
  } else if (duration <= 36000000) {
    result = '< 10 hours left';
  } else if (duration <= 39600000) {
    result = '< 11 hours left';
  } else if (duration <= 43200000) {
    result = '< 12 hours left';
  } else {
    result = 'lots of time left';
  }
  return result;
}

void kHandleRemoveChatFromActivityFeed(String chatId, String collection) {
  usersInChatRef
      .document(chatId)
      .collection(collection)
      .snapshots()
      .forEach((snapshot) {
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        final uid = doc.data['uid'];
        activityRef
            .document(uid)
            .collection('feedItems')
            .document(chatId)
            .delete();
      }
    });
  });
}

void kHandleRemoveEntireNode(String collection, String id) {
  final ref = Firestore.instance.collection(collection).document(id);
  ref.get().then((snapshot) {
    if (snapshot.exists) {
      ref.delete();
    }
  });
}

void kHandleRemoveUsersInChat(String chatId, String collection) {
  usersInChatRef
      .document(chatId)
      .collection(collection)
      .snapshots()
      .forEach((snapshot) {
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  });
}

void kHandleRemoveAllLiveChatData(String chatId, String uid) {
  kHandleRemoveChatFromActivityFeed(chatId, 'inChat');
  kHandleRemoveChatFromActivityFeed(chatId, 'invited');
  kHandleRemoveUsersInChat(chatId, 'invited');
  kHandleRemoveUsersInChat(chatId, 'inChat');
  kHandleRemoveEntireNode('liveChatLocations', chatId);
  kRemoveLiveChatMessages(chatId);
  kHandleRemoveDataAtId(chatId, uid, 'liveChats', 'chats');
}

void kShowSnackbar(
    {GlobalKey<ScaffoldState> key, String text, Color backgroundColor}) {
  key.currentState.hideCurrentSnackBar();
  kHeavyImpact();
  SnackBar snackbar = SnackBar(
    elevation: 2.0,
    duration: Duration(seconds: 5),
    content: Text(
      text,
      style: kDefaultTextStyle.copyWith(color: Colors.white, fontSize: 15.0,),
      textAlign: TextAlign.center,
    ),
    backgroundColor: backgroundColor,
  );
  key.currentState.showSnackBar(snackbar);
}

void kUpdateHideMe(bool val) {
  userLocationsRef.document(currentUser.uid).updateData({
    'hideMe': val
  });
}

void kHandleHideMe(GlobalKey<ScaffoldState> key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hideMe = prefs.getBool('hideMe') ?? false;
  if (!hideMe) {
    await prefs.setBool('hideMe', true);
    kUpdateHideMe(true);
    kShowSnackbar(
      key: key,
      text: 'Hide Me Active: you will not be seen by people nearby, and you cannot see any content nearby',
      backgroundColor: kColorGreen,
    );
  } else {
    await prefs.setBool('hideMe', false);
    kUpdateHideMe(false);
    kShowSnackbar(
      key: key,
      text: 'Hide Me Disabled',
      backgroundColor: kColorBlue,
    );
  }
}

void kSelectionClick() {
  SystemChannels.platform.invokeMethod<void>(
    'HapticFeedback.vibrate',
    'HapticFeedbackType.selectionClick');
}

void kHeavyImpact() {
  SystemChannels.platform.invokeMethod<void>(
    'HapticFeedback.vibrate',
    'HapticFeedbackType.heavyImpact');
}