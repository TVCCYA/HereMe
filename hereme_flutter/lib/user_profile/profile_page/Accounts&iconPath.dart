
List<Accounts> linkedAccounts = [];

class Accounts {
  Accounts({this.socialMediaHandle, this.icon, this.socialMediaUrl});
  final String socialMediaHandle;
  final String icon;
  final String socialMediaUrl;
}

String iconPath(String socialmedia) {
  switch (socialmedia) {
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
        print("couldn't find social media username to link");
      }
  }
}