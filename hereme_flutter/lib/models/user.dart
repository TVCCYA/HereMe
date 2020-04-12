import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String profileImageUrl;
  String uid;
  String username;
  int totalVisitsCount;
  int weeklyVisitsCount;
  bool hasAccountLinked;
  bool isVerified;
  String displayName;
  String city;
  int red;
  int green;
  int blue;
  Map<dynamic, dynamic> blockedUserUids;
  List<String> blockedUids;
  String backgroundImageUrl;
  String videoUrl;
  String bio;

  User({
    this.username,
    this.uid,
    this.profileImageUrl,
    this.totalVisitsCount,
    this.weeklyVisitsCount,
    this.hasAccountLinked,
    this.isVerified,
    this.displayName,
    this.city,
    this.red,
    this.green,
    this.blue,
    this.blockedUserUids,
    this.blockedUids,
    this.backgroundImageUrl,
    this.videoUrl,
    this.bio
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['uid'],
      username: doc['username'],
      profileImageUrl: doc['profileImageUrl'],
      totalVisitsCount: doc['totalVisitsCount'],
      weeklyVisitsCount: doc['weeklyVisitsCount'],
      hasAccountLinked: doc['hasAccountLinked'],
      isVerified: doc['isVerified'],
      displayName: doc['displayName'],
      city: doc['city'] ?? 'Around',
      red: doc['red'] ?? 0,
      green: doc['green'] ?? 0,
      blue: doc['blue'] ?? 0,
      blockedUserUids: doc['blockedUsers'],
      backgroundImageUrl: doc['backgroundImageUrl'],
      videoUrl: doc['videoUrl'] ?? '',
      bio: doc['bio'] ?? '',
    );
  }
}
