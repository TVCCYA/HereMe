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
    );
  }
}
