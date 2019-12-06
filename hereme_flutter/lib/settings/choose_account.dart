import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/models/social_media.dart';
import 'add_link.dart';

class ChooseAccount extends StatefulWidget {
  @override
  _ChooseAccountState createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<SocialMedias> allMedias = [
    SocialMedias(
      platform: 'Instagram',
      icon: 'images/SocialMedias/instagram120.png',
      color: kColorInstagram,
    ),
    SocialMedias(
        platform: 'Snapchat',
        icon: 'images/SocialMedias/snapchat120.png',
        color: kColorSnapchat),
    SocialMedias(
        platform: 'TikTok',
        icon: 'images/SocialMedias/tiktok120.png',
        color: kColorTikTok),
    SocialMedias(
        platform: 'YouTube',
        icon: 'images/SocialMedias/youtube120.png',
        color: kColorYoutube),
    SocialMedias(
        platform: 'Twitter',
        icon: 'images/SocialMedias/twitter120.png',
        color: kColorTwitter),
    SocialMedias(
        platform: 'Facebook',
        icon: 'images/SocialMedias/facebook120.png',
        color: kColorFacebook),
    SocialMedias(
        platform: 'Reddit',
        icon: 'images/SocialMedias/reddit120.png',
        color: kColorReddit),
    SocialMedias(
        platform: 'Twitch',
        icon: 'images/SocialMedias/twitch120.png',
        color: kColorTwitch),
    SocialMedias(
        platform: 'Venmo',
        icon: 'images/SocialMedias/venmo120.png',
        color: kColorVenmo),
    SocialMedias(
        platform: 'Tumblr',
        icon: 'images/SocialMedias/tumblr120.png',
        color: kColorTumblr),
    SocialMedias(
        platform: 'Pinterest',
        icon: 'images/SocialMedias/pinterest120.png',
        color: kColorPinterest),
    SocialMedias(
        platform: 'SoundCloud',
        icon: 'images/SocialMedias/soundcloud120.png',
        color: kColorSoundcloud),
    SocialMedias(
        platform: 'Spotify',
        icon: 'images/SocialMedias/spotify120.png',
        color: kColorSpotify),
    SocialMedias(
        platform: 'Your Website',
        icon: 'images/SocialMedias/website.png',
        color: kColorLightGray),
  ];

  buildTiles() {
    List<GridTile> gridTiles = [];
    allMedias.forEach((media) {
      gridTiles.add(GridTile(
          child: SocialMediaTile(
        socialMedia: media,
        scaffoldKey: _scaffoldKey,
      )));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GridView.count(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: 2.0, right: 2.0),
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          shrinkWrap: true,
          children: gridTiles,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          'Link Account',
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
      body: SafeArea(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: buildTiles(),
          ),
        ),
      ),
    );
  }
}

class SocialMediaTile extends StatelessWidget {
  final SocialMedias socialMedia;
  final Function onTap;
  final GlobalKey<ScaffoldState> scaffoldKey;
  SocialMediaTile({this.socialMedia, this.onTap, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      splashColor: socialMedia.color.withOpacity(0.1),
      onPressed: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLink(
                platform: socialMedia.platform,
                color: socialMedia.color,
                icon: socialMedia.icon,
              ),
            ));
        kShowSnackbar(
          key: scaffoldKey,
          text: '$result',
          backgroundColor: kColorGreen,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              socialMedia.color.withOpacity(0.6),
              socialMedia.color.withOpacity(0.45),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              socialMedia.platform,
              style: kDefaultTextStyle.copyWith(
                fontSize: 18.0,
                color: socialMedia.platform != 'Snapchat' &&
                        socialMedia.platform != 'Your Website' &&
                        socialMedia.platform != 'TikTok'
                    ? Colors.white
                    : kColorBlack71,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
