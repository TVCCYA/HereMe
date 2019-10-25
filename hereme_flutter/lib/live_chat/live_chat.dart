import 'package:cloud_firestore/cloud_firestore.dart';

class LiveChat {
  String uid;
  String chatId;
  String hostUsername;
  String title;
  String duration;
  List<String> invites;
  int creationDate;

  LiveChat({
    this.uid,
    this.chatId,
    this.hostUsername,
    this.title,
    this.duration,
    this.invites,
    this.creationDate,
  });

  factory LiveChat.fromDocument(DocumentSnapshot doc) {
    return LiveChat(
      uid: doc['uid'],
      chatId: doc['chatId'],
      hostUsername: doc['hostUsername'] ?? '',
      title: doc['title'],
      duration: doc['duration'],
      invites: doc['invites'],
      creationDate: doc['creationDate'],
    );
  }
}