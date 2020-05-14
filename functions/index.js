const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onCreateActivityFeedItem = functions.firestore
    .document('/activity/{userId}/feedItems/{activityFeedItem}')
    .onCreate(async  (snapshot, context) => {

        // 1) Get user connected to the feed
        const userId = context.params.userId;
        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();
        const username = doc.data().username;

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const activityFeedItem = snapshot.data();
        const hostDisplayName = snapshot.data().hostDisplayName;

        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, activityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;

            if (activityFeedItem.type === "liveChatInvite") {
                if (hostDisplayName !== '') {
                    body = `${hostDisplayName} invited you to their Live Chat: ${activityFeedItem.title}!`;
                } else {
                    body = `You have been anonymously invited to Live Chat: ${activityFeedItem.title}`
                }
            }

            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: userId},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                console.log(`${hostDisplayName} sent message to ${username}`, response);
            }).catch(error => {
                console.log("Error sending message: ", error);
            })
        }
    });

exports.onCreateKnock = functions.firestore
    .document('/knocks/{currentUserUid}/receivedKnockFrom/{userId}')
    .onCreate(async  (snapshot, context) => {

        // 1) Get user connected to the feed
        const userId = context.params.userId;
        const currentUserUid = context.params.currentUserUid;
        const currentUserRef = admin.firestore().doc(`users/${currentUserUid}`);
        const currentUserDoc = await currentUserRef.get();
        const userRef = admin.firestore().doc(`users/${userId}`);
        const knockUserDoc = await userRef.get();

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = currentUserDoc.data().androidNotificationToken;
        const knockData = snapshot.data();

        if (androidNotificationToken) {
            // send notification
            sendNotification(androidNotificationToken, knockData);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, knockData) {
            let body = `${knockUserDoc.data().username} is knocking!`;

            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: currentUserUid},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                console.log(`${knockUserDoc.data().username} Successfully sent message to ${currentUserUid}`, response);
            }).catch(error => {
                console.log("Error sending message ", error);
            })
        }
    });

exports.onCreateNearbyUser = functions.firestore
    .document("/usersNearby/{currentUserUid}/users/{uid}")
    .onCreate(async (snapshot, context) => {
        console.log("Fetched nearby user", snapshot.data());
        const currentUserUid = context.params.currentUserUid;
        const uid = context.params.uid;

        const userRef = admin.firestore().doc(`users/${uid}`);
        const userDoc = await userRef.get();
        const profileImageUrl = userDoc.data().profileImageUrl;
        const displayName = userDoc.data().displayName;

        // 1) get followed users posts ref
        const nearbyUserPostRef = admin
            .firestore()
            .collection("update")
            .doc(uid)
            .collection("posts");

        // 2) get following user's timeline ref
        const timelinePostsRef = admin
            .firestore()
            .collection("timeline")
            .doc(currentUserUid)
            .collection("timelinePosts");

        // 3) get followed users posts
        const querySnapshot = await nearbyUserPostRef.get();

        // 4) add each user post to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                const creationDate = postData.creationDate;
                const likes = postData.likes;
                const photoUrl = postData.photoUrl;
                const title = postData.title;
                const type = postData.type;
                const uid = postData.uid;
                if (type === 'photo') {
                    timelinePostsRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'photoUrl': photoUrl,
                        'title': title,
                        'type': type,
                        'uid': uid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                } else if (type === 'text') {
                    timelinePostsRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'title': title,
                        'type': type,
                        'uid': uid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                }
            }
        });
    });

exports.onRemoveNearbyUser = functions.firestore
    .document("/usersNearby/{currentUserUid}/users/{uid}")
    .onDelete(async (snapshot, context) => {
        console.log("Nearby user left", snapshot.id);
        const currentUserUid = context.params.currentUserUid;
        const uid = context.params.uid;

        admin.firestore()
            .collection('usersNearby')
            .doc(uid)
            .collection('users')
            .doc(currentUserUid)
            .get().then(doc => {
                if (doc.exists) {
                    doc.ref.delete();
                }
            });

        const timelinePostsRef = admin.firestore()
            .collection("timeline")
            .doc(currentUserUid)
            .collection("timelinePosts")
            .where("uid", "==", uid);
        const querySnapshot = await timelinePostsRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });

exports.onCreateTopUser = functions.firestore
    .document("/topUsers/{uid}")
    .onCreate(async (snapshot, context) => {
        console.log("Fetched top user", snapshot.data());
        const uid = context.params.uid;

        const userRef = admin.firestore().doc(`users/${uid}`);
        const userDoc = await userRef.get();
        const profileImageUrl = userDoc.data().profileImageUrl;
        const displayName = userDoc.data().displayName;

        // 1) get followed users posts ref
        const topUserPostRef = admin
            .firestore()
            .collection("update")
            .doc(uid)
            .collection("posts");

        // 2) get following user's timeline ref
        const exploreTimelinePostsRef = admin
            .firestore()
            .collection("exploreTimeline");

        // 3) get followed users posts
        const querySnapshot = await topUserPostRef.get();

        // 4) add each user post to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                const creationDate = postData.creationDate;
                const likes = postData.likes;
                const photoUrl = postData.photoUrl;
                const title = postData.title;
                const type = postData.type;
                const uid = postData.uid;
                if (type === 'photo') {
                    exploreTimelinePostsRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'photoUrl': photoUrl,
                        'title': title,
                        'type': type,
                        'uid': uid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                } else if (type === 'text') {
                    exploreTimelinePostsRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'title': title,
                        'type': type,
                        'uid': uid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                }
            }
        });
    });

exports.onRemoveTopUser = functions.firestore
    .document("/topUsers/{uid}")
    .onDelete(async (snapshot, context) => {
        console.log("top user not top", snapshot.id);
        const uid = context.params.uid;

        const exploreTimelinePostsRef = admin
            .firestore()
            .collection("exploreTimeline")
            .where("uid", "==", uid);

        const querySnapshot = await exploreTimelinePostsRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });

exports.onCreateLatestPost = functions.firestore
    .document('/update/{currentUserUid}/posts/{postId}')
    .onCreate(async (snapshot, context) => {
        console.log("created post", snapshot.id);
        const currentUserUid = context.params.currentUserUid;
        const postId = context.params.postId;
        const creationDate = snapshot.data().creationDate;
        const photoUrl = snapshot.data().photoUrl;
        const likes = snapshot.data().likes;
        const title = snapshot.data().title;
        const type = snapshot.data().type;

        const userRef = admin.firestore().doc(`users/${currentUserUid}`);
        const userDoc = await userRef.get();
        const profileImageUrl = userDoc.data().profileImageUrl;
        const displayName = userDoc.data().displayName;

        const usersNearbyRef = admin.firestore()
            .collection('usersNearby')
            .doc(currentUserUid)
            .collection('users');
        const querySnapshot = await usersNearbyRef.get();
        querySnapshot.forEach(doc => {
            const uid = doc.id;
            const timelineRef = admin.firestore()
                .collection("timeline")
                .doc(uid)
                .collection("timelinePosts");
            if (type === 'photo') {
                timelineRef.doc(postId).set({
                    'creationDate': creationDate,
                    'id': postId,
                    'likes': likes,
                    'photoUrl': photoUrl,
                    'title': title,
                    'type': type,
                    'uid': currentUserUid,
                    'profileImageUrl': profileImageUrl,
                    'displayName': displayName,
                });
            } else if (type === 'text') {
                timelineRef.doc(postId).set({
                    'creationDate': creationDate,
                    'id': postId,
                    'likes': likes,
                    'title': title,
                    'type': type,
                    'uid': currentUserUid,
                    'profileImageUrl': profileImageUrl,
                    'displayName': displayName,
                });
            }
        });

        const topUsersRef = admin.firestore()
            .collection('topUsers');
        const exploreTimelineRef = admin.firestore()
            .collection('exploreTimeline');
        const topUsersQuerySnapshot = await topUsersRef.get();
        topUsersQuerySnapshot.forEach(doc => {
            const uid = doc.id;
            if (currentUserUid === uid) {
                if (type === 'photo') {
                    exploreTimelineRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'photoUrl': photoUrl,
                        'title': title,
                        'type': type,
                        'uid': currentUserUid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                } else if (type === 'text') {
                    exploreTimelineRef.doc(postId).set({
                        'creationDate': creationDate,
                        'id': postId,
                        'likes': likes,
                        'title': title,
                        'type': type,
                        'uid': currentUserUid,
                        'profileImageUrl': profileImageUrl,
                        'displayName': displayName,
                    });
                }
            }
        });
    });

exports.onRemoveLatestPost = functions.firestore
    .document('/update/{currentUserUid}/posts/{postId}')
    .onDelete(async (snapshot, context) => {
        console.log("removing post", snapshot.id);
        const currentUserUid = context.params.currentUserUid;
        const postId = context.params.postId;

        const usersNearbyRef = admin.firestore()
            .collection('usersNearby')
            .doc(currentUserUid)
            .collection('users');
        const querySnapshot = await usersNearbyRef.get();
        querySnapshot.forEach(doc => {
            const uid = doc.id;
            admin.firestore()
                .collection("timeline")
                .doc(uid)
                .collection("timelinePosts")
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
            })
        });

        admin.firestore()
            .collection("exploreTimeline")
            .doc(postId).get().then(doc => {
                if (doc.exists) {
                    doc.ref.delete();
                }
            });
    });

exports.onUpdateDisplayName = functions.firestore
    .document('/users/{currentUserUid}/updatedFields/displayName')
    .onUpdate(async (change, context) => {
        const displayName = change.after.data().displayName;
        const currentUserUid = context.params.currentUserUid;

        // UPDATES EXPLORE TIMELINE
        const exploreTimelineRef = admin.firestore()
            .collection('exploreTimeline')
            .where("uid", "==", currentUserUid);
        const querySnapshot = await exploreTimelineRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.update({
                    'displayName': displayName,
                });
            }
        });

        // UPDATES TIMELINE
        const usersNearbyRef = admin.firestore()
            .collection('usersNearby')
            .doc(currentUserUid)
            .collection('users');
        const usersSnapshot = await usersNearbyRef.get();
        usersSnapshot.forEach(doc => {
            const uid = doc.id;
            admin.firestore()
                .collection("timeline")
                .doc(uid)
                .collection("timelinePosts")
                .where("uid", "==", currentUserUid)
                .get().then(doc => doc.forEach( snap => {
                    if (snap.exists) {
                        snap.ref.update({
                            'displayName': displayName,
                        });
                    }
                })
            );
        });

        // UPDATES KNOCKS
        const knocksRef = admin.firestore()
            .collection('knocks')
            .doc(currentUserUid)
            .collection('sentKnockTo');
        const knocksSnapshot = await knocksRef.get();
        knocksSnapshot.forEach(doc => {
            const uid = doc.id;
            admin.firestore()
                .collection('knocks')
                .doc(uid)
                .collection('receivedKnockFrom')
                .where("uid", "==", currentUserUid)
                .get().then(doc => doc.forEach(snap => {
                if (snap.exists) {
                    snap.ref.update({
                        'displayName': displayName,
                    });
                }
            }))
        });
    });

exports.onUpdateProfileImage = functions.firestore
    .document('/users/{currentUserUid}/updatedFields/profileImageUrl')
    .onUpdate(async (change, context) => {
        const profileImageUrl = change.after.data().profileImageUrl;
        const currentUserUid = context.params.currentUserUid;

        // UPDATES EXPLORE TIMELINE
        const exploreTimelineRef = admin.firestore()
            .collection('exploreTimeline')
            .where("uid", "==", currentUserUid);
        const querySnapshot = await exploreTimelineRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.update({
                    'profileImageUrl': profileImageUrl,
                });
            }
        });

        // UPDATES TIMELINE
        const usersNearbyRef = admin.firestore()
            .collection('usersNearby')
            .doc(currentUserUid)
            .collection('users');
        const usersSnapshot = await usersNearbyRef.get();
        usersSnapshot.forEach(doc => {
            const uid = doc.id;
            admin.firestore()
                .collection("timeline")
                .doc(uid)
                .collection("timelinePosts")
                .where("uid", "==", currentUserUid)
                .get().then(doc => doc.forEach( snap => {
                    if (snap.exists) {
                        snap.ref.update({
                            'profileImageUrl': profileImageUrl,
                        });
                    }
                })
            );
        });

        // UPDATES KNOCKS
        const knocksRef = admin.firestore()
            .collection('knocks')
            .doc(currentUserUid)
            .collection('sentKnockTo');
        const knocksSnapshot = await knocksRef.get();
        knocksSnapshot.forEach(doc => {
            const uid = doc.id;
            admin.firestore()
                .collection('knocks')
                .doc(uid)
                .collection('receivedKnockFrom')
                .where("uid", "==", currentUserUid)
                .get().then(doc => doc.forEach(snap => {
                if (snap.exists) {
                    snap.ref.update({
                        'profileImageUrl': profileImageUrl,
                    });
                }
            }))
        });
    });

exports.onCreateSamePostLike = functions.firestore
    .document('/activity/{currentUserUid}/feedItems/{id}')
    .onCreate(async (snapshot, context) => {
        console.log("adding like", snapshot.id);
        const currentUserUid = context.params.currentUserUid;
        const id = context.params.id;

        const activityRef = admin.firestore()
            .collection('activity')
            .doc(currentUserUid)
            .collection('feedItems');
        const querySnapshot = await activityRef.get();
        querySnapshot.forEach(doc => {
            const id = doc.id;
            const postId = doc.data().postId;
            const type = doc.data().type;
            if (type === 'like') {
                console.log('id: ', id, ' liked post id: ', postId);
            }
        });
    });