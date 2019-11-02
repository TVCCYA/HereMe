import 'package:cloud_firestore/cloud_firestore.dart';

class LiveChat {
  String uid;
  String chatId;
  String hostDisplayName;
  String title;
  String duration;
  List<String> invites;
  int creationDate;

  LiveChat({
    this.uid,
    this.chatId,
    this.hostDisplayName,
    this.title,
    this.duration,
    this.invites,
    this.creationDate,
  });

  factory LiveChat.fromDocument(DocumentSnapshot doc) {
    return LiveChat(
      uid: doc['uid'],
      chatId: doc['chatId'],
      hostDisplayName: doc['hostDisplayName'] ?? '',
      title: doc['title'],
      duration: doc['duration'],
      invites: doc['invites'],
      creationDate: doc['creationDate'],
    );
  }
}