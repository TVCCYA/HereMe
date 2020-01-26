import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String profileImageUrl;
  String uid;
  String username;
  int totalVisitsCount;
  int weeklyVisitsCount;
  bool hasAccountLinked;
  bool isVerified;
  String storageFilename;
  String displayName;
  String city;
  int red;
  int green;
  int blue;
  Map<dynamic, dynamic> blockedUserUids;
  List<String> blockedUids;
  String backgroundImageUrl;

  User({
    this.username,
    this.uid,
    this.profileImageUrl,
    this.totalVisitsCount,
    this.weeklyVisitsCount,
    this.hasAccountLinked,
    this.isVerified,
    this.storageFilename,
    this.displayName,
    this.city,
    this.red,
    this.green,
    this.blue,
    this.blockedUserUids,
    this.blockedUids,
    this.backgroundImageUrl,
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
      storageFilename: doc['storageFilename'],
      displayName: doc['displayName'],
      city: doc['city'],
      red: doc['red'],
      green: doc['green'],
      blue: doc['blue'],
      blockedUserUids: doc['blockedUsers'],
      backgroundImageUrl: doc['backgroundImageUrl'],
    );
  }
}
