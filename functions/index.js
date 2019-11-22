const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.onCreateActivityFeedItem = functions.firestore
    .document('/activity/{userId}/feedItems/{activityFeedItem}')
    .onCreate(async  (snapshot, context) => {
        console.log('Activity Feed Item Created', snapshot.data());

        // 1) Get user connected to the feed
        const userId = context.params.userId;
        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const activityFeedItem = snapshot.data();

        if (androidNotificationToken) {
            // send notification
            sendNotification(androidNotificationToken, activityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body = `${activityFeedItem.username} invited you to their Live Chat: ${activityFeedItem.title}`;

            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: userId},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                // Response is a message ID string
                console.log("Successfully send message", response);
            }).catch(error => {
                console.log("Error sending message", error);
            })
        }
    });


exports.onCreateKnock = functions.firestore
    .document('/knocks/{currentUserUid}/receivedKnockFrom/{userId}')
    .onCreate(async  (snapshot, context) => {
        console.log('Knock created', snapshot.data());

        // 1) Get user connected to the feed
        const currentUserUid = context.params.currentUserUid;
        const userRef = admin.firestore().doc(`users/${currentUserUid}`);
        const doc = await userRef.get();

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const knockData = snapshot.data();

        if (androidNotificationToken) {
            // send notification
            sendNotification(androidNotificationToken, knockData);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, knockData) {
            let body = `${knockData.username} is knocking!`;

            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: currentUserUid},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                // Response is a message ID string
                console.log(`${knockData.username} Successfully sent message to ${currentUserUid}`, response);
            }).catch(error => {
                console.log("Error sending message", error);
            })
        }
    });