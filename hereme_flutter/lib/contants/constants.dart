import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const kColorPurple = Color.fromRGBO(111, 89, 194, 1.0);
const kColorBlue = Color.fromRGBO(71, 106, 188, 1.0);
const kColorGreen = Color.fromRGBO(71, 188, 153, 1.0);

const kColorBlack105 = Color.fromRGBO(105, 105, 105, 1.0);
const kColorOffWhite = Color.fromRGBO(245, 245, 245, 1.0);
const kColorOffBlack = Color.fromRGBO(50, 50, 50, 1.0);
const kColorLightGray = Color.fromRGBO(188, 188, 188, 1.0);
const kColorRed = Color.fromRGBO(188, 71, 89, 1.0);
const kColorThistle = Color.fromRGBO(197, 188, 230, 1.0);
const kColorDarkThistle = Color.fromRGBO(164, 150, 216, 1.0);
// SOCIAL MEDIA COLORS
const kColorInstagramColor = Color.fromRGBO(131, 58, 180, 1.0);
const kColorSnapchatColor = Color.fromRGBO(255, 252, 0, 1.0);
const kColorTwitterColor = Color.fromRGBO(29, 161, 242, 1.0);
const kColorFacebookColor = Color.fromRGBO(59, 89, 152, 1.0);
const kColorYoutubeColor = Color.fromRGBO(255, 0, 0, 1.0);
const kColorSoundcloudColor = Color.fromRGBO(255, 136, 0, 1.0);
const kColorPinterestColor = Color.fromRGBO(189, 8, 28, 1.0);
const kColorSpotifyColor = Color.fromRGBO(30, 215, 96, 1.0);
const kColorVenmoColor = Color.fromRGBO(61, 149, 206, 1.0);
const kColorTumblrColor = Color.fromRGBO(53, 70, 92, 1.0);
const kColorRedditColor = Color.fromRGBO(255, 69, 0, 1.0);
const kColorLinkedInColor = Color.fromRGBO(0, 119, 181, 1.0);
const kColorTwitchColor = Color.fromRGBO(100, 65, 164, 1.0);

ThemeData kTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    accentColor: kColorBlue,
    unselectedWidgetColor: kColorLightGray,
    dividerColor: Colors.grey[200],
    highlightColor: Colors.transparent,
    splashColor: Colors.grey[200],
  );
}

const kDefaultTextStyle = TextStyle(
  color: kColorBlack105,
  fontFamily: 'Arimo',
  fontSize: 16.0,
  fontWeight: FontWeight.w300
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

const kAppBarTextStyle = TextStyle(
  fontFamily: 'Arimo',
  fontSize: 18.0,
  color: kColorBlack105,
  fontWeight: FontWeight.w600,
);

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
        color: kColorBlack105,
        fontSize: 24.0,
      ),
      descStyle: kDefaultTextStyle.copyWith(
        color: kColorBlack105,
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
        color: kColorBlack105,
        fontSize: 24.0,
      ),
      descStyle: kDefaultTextStyle.copyWith(
        color: kColorBlack105,
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
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kColorPurple),
      backgroundColor: kColorLightGray,
    ),
  );
}
