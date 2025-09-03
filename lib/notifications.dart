import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

/// This function handles all push notification setup.
/// It requests permission and saves the FCM token to Firestore.
Future<void> setupPushNotifications() async {
  final fcm = FirebaseMessaging.instance;
  final user = FirebaseAuth.instance.currentUser;

  // Exit if the user is not logged in
  if (user == null) {
    if (kDebugMode) {
      print("Notification setup skipped: User is not logged in.");
    }
    return;
  }

  try {
    // 1. Request permission from the user to show notifications
    await fcm.requestPermission();

    // 2. Get the unique device token (the "address")
    final token = await fcm.getToken();

    // 3. Save the token to the current user's document in Firestore
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true), // Use merge to avoid overwriting other fields
      );

      if (kDebugMode) {
        print('FCM Token saved for user ${user.uid}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error setting up push notifications: $e');
    }
  }
}
