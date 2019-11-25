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

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const activityFeedItem = snapshot.data();
        const hostDisplayName = snapshot.data()["hostDisplayName"];
        const username = doc.data().username;

        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, activityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;

            switch (activityFeedItem.type) {
                case "liveChatInvite":
                    body = `${hostDisplayName} invited you to their Live Chat: ${activityFeedItem.title}`;
                    break;
                case "liveChatMessage":
                    break;
                default:
                    break;
            }
            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: userId},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                // Response is a message ID string
                console.log(`${hostDisplayName} successfully invited ${username} to chat: ${activityFeedItem.title}`, response);
            }).catch(error => {
                console.log("Error sending message: ", error);
            })
        }
    });


exports.onCreateKnock = functions.firestore
    .document('/knocks/{userId}/receivedKnockFrom/{currentUserUid}')
    .onCreate(async  (snapshot, context) => {

        // 1) Get user connected to the feed
        const userId = context.params.userId;
        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        // 2) Once we have user, check if they have a notification token;
        // send notification if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const knockData = snapshot.data();
        const username = doc.data().username;

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
                data: {recipient: userId},
            };

            // 5) Send message with admin.messaging()
            admin.messaging().send(message).then(response => {
                // Response is a message ID string
                console.log(`${knockData.username} Successfully sent message to ${username}`, response);
            }).catch(error => {
                console.log("Error sending message ", error);
            })
        }
    });