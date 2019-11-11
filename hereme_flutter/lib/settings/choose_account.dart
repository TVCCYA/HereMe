import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'add_account.dart';
import 'add_link.dart';

class ChooseAccount extends StatefulWidget {
  @override
  _ChooseAccountState createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {

  List<SocialMedias> allMedias = [
    SocialMedias(
        platform: 'Instagram',
        icon: 'images/SocialMedias/instagram120.png',
        color: kColorInstagramColor),
    SocialMedias(
        platform: 'Snapchat',
        icon: 'images/SocialMedias/snapchat120.png',
        color: kColorSnapchatColor),
    SocialMedias(
        platform: 'Twitter',
        icon: 'images/SocialMedias/twitter120.png',
        color: kColorTwitterColor),
    SocialMedias(
        platform: 'YouTube',
        icon: 'images/SocialMedias/youtube120.png',
        color: kColorYoutubeColor),
    SocialMedias(
        platform: 'Reddit',
        icon: 'images/SocialMedias/reddit120.png',
        color: kColorRedditColor),
    SocialMedias(
        platform: 'Twitch',
        icon: 'images/SocialMedias/twitch120.png',
        color: kColorTwitchColor),
    SocialMedias(
        platform: 'SoundCloud',
        icon: 'images/SocialMedias/soundcloud120.png',
        color: kColorSoundcloudColor),
    SocialMedias(
        platform: 'Venmo',
        icon: 'images/SocialMedias/venmo120.png',
        color: kColorVenmoColor),
    SocialMedias(
        platform: 'Spotify',
        icon: 'images/SocialMedias/spotify120.png',
        color: kColorSpotifyColor),
    SocialMedias(
        platform: 'Tumblr',
        icon: 'images/SocialMedias/tumblr120.png',
        color: kColorTumblrColor),
    SocialMedias(
        platform: 'Facebook',
        icon: 'images/SocialMedias/facebook120.png',
        color: kColorFacebookColor),
    SocialMedias(
        platform: 'Your Website',
        icon: 'images/SocialMedias/facebook120.png',
        color: kColorLightGray),
  ];

  buildTiles() {
    List<GridTile> gridTiles = [];
    allMedias.forEach((media) {
      gridTiles.add(GridTile(
          child: SocialMediaTile(
              socialMedia: media)));
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
      backgroundColor: kColorOffWhite,
      appBar: AppBar(
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
  SocialMediaTile({this.socialMedia, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddLink(
            platform: socialMedia.platform,
            color: socialMedia.color,
            icon: socialMedia.icon,
          ),
        ),
      ),
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
                          socialMedia.platform != 'Your Website'
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
