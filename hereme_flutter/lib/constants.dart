import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'home/home.dart';

const kColorPurple = Color.fromRGBO(95, 71, 188, 1.0);
const kColorBlue = Color.fromRGBO(71, 106, 188, 1.0);
const kColorGreen = Color.fromRGBO(71, 188, 153, 1.0);

const kColorBlack71 = Color.fromRGBO(71, 71, 71, 1.0);
const kColorOffWhite = Color.fromRGBO(245, 245, 245, 1.0);
const kColorOffBlack = Color.fromRGBO(11, 8, 19, 1.0);
const kColorLightGray = Color.fromRGBO(188, 188, 188, 1.0);
const kColorRed = Color.fromRGBO(188, 71, 89, 1.0);
const kColorThistle = Color.fromRGBO(197, 188, 230, 1.0);
const kColorDarkThistle = Color.fromRGBO(164, 150, 216, 1.0);
// SOCIAL MEDIA COLORS
const kColorInstagramColor = Color.fromRGBO(185, 0, 180, 1.0);
const kColorSnapchatColor = Color.fromRGBO(255, 252, 0, 1.0);
const kColorTwitterColor = Color.fromRGBO(29, 161, 242, 1.0);
const kColorFacebookColor = Color.fromRGBO(21, 120, 242, 1.0);
const kColorYoutubeColor = Color.fromRGBO(255, 0, 0, 1.0);
const kColorSoundcloudColor = Color.fromRGBO(255, 136, 0, 1.0);
const kColorPinterestColor = Color.fromRGBO(189, 8, 28, 1.0);
const kColorSpotifyColor = Color.fromRGBO(30, 215, 96, 1.0);
const kColorVenmoColor = Color.fromRGBO(61, 149, 206, 1.0);
const kColorTumblrColor = Color.fromRGBO(53, 70, 92, 1.0);
const kColorRedditColor = Color.fromRGBO(255, 69, 0, 1.0);
const kColorLinkedInColor = Color.fromRGBO(0, 119, 181, 1.0);
const kColorTwitchColor = Color.fromRGBO(145, 70, 255, 1.0);

ThemeData kTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    accentColor: kColorBlue,
    unselectedWidgetColor: kColorLightGray,
    dividerColor: Colors.grey[200],
    highlightColor: Colors.transparent,
    splashColor: Colors.grey[200],
  );
}

const kAppBarTextStyle = TextStyle(
  fontFamily: 'Avenir',
  fontSize: 18.0,
  color: kColorBlack71,
  fontWeight: FontWeight.bold,
);

const kDefaultTextStyle = TextStyle(
  color: kColorBlack71,
  fontFamily: 'Avenir',
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
);

const kRegistrationInputDecoration = InputDecoration(
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kColorLightGray,
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: kColorThistle),
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

void kShowAlert(
    {context: BuildContext,
    title: String,
    desc: String,
    buttonText: String,
    onPressed: Function}) {
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
        color: kColorRed,
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
  color: kColorPurple,
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
      valueColor: AlwaysStoppedAnimation(kColorPurple),
      backgroundColor: kColorLightGray,
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.all(10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kColorPurple),
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
      kBlockUser(context, uid);
      Navigator.pop(context);
    },
  );
}

void kBlockUser(BuildContext context, String uid) {
  usersRef.document(currentUser.uid).updateData({
    'blockedUsers.$uid': 1,
  }).whenComplete(() {
    usersRef.document(uid).updateData({
      'blockedUsers.$uid': 0,
    }).whenComplete(() {
      kShowFlushBar(
          context: context,
          text: 'Successfully Blocked',
          color: kColorGreen,
          icon: FontAwesomeIcons.exclamation);
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
  final ref = activityRef.document(currentUserUid).collection('feedItems');
  ref.getDocuments().then((snapshot) {
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        final type = doc.data['type'];
        if (type == 'pendingKnock') {
          final sentKnockUid = doc.data['uid'];
          knocksRef.document(sentKnockUid).collection('receivedKnockFrom').document(currentUserUid).get().then((doc){
            if (doc.exists) {
              doc.reference.delete().whenComplete(() {
                ref.document(sentKnockUid).delete();
              });
            }
          });
        }
      }
    });
  });
}


void kHandleRemoveData(String key, String uid, String collection1, String collection2) async {
  final ref = Firestore
      .instance
      .collection(collection1)
      .document(uid)
      .collection(collection2);

  ref.getDocuments().then((snapshot) {
    for (final doc in snapshot.documents) {
      if (doc.exists) {
        if (doc.data.containsValue(key)) {
          ref.document(doc.documentID).delete();
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