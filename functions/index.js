// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// This is our "Postal Worker" function
// It automatically runs when a new message is created
exports.sendNewMessageNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot) => {
    // 1. Get the new message data
    const message = snapshot.data();
    const receiverId = message.receiverId;
    const senderId = message.senderId;

    // 2. Get the sender's name (to show in the notification)
    const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
    const senderName = senderDoc.data().name;

    // 3. Get the receiver's "address" (FCM Token)
    const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
    const fcmToken = receiverDoc.data().fcmToken;

    // Make sure the receiver has an address before trying to send
    if (!fcmToken) {
      return console.log("Cannot send notification, receiver has no FCM token.");
    }

    // 4. Create the notification message
    const payload = {
      notification: {
        title: `New message from ${senderName}`,
        body: message.text, // The text from the message document
      },
    };

    // 5. Send the notification to the receiver's phone
    console.log(`Sending notification to token: ${fcmToken}`);
    return admin.messaging().sendToDevice(fcmToken, payload);
  });