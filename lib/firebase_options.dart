
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
         throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyAD4iaxeBcW3HnidnlK9upFpvWA6AtLxn4",
  authDomain: "skillswap-1f230.firebaseapp.com",
  projectId: "skillswap-1f230",
  storageBucket: "skillswap-1f230.firebasestorage.app",
  messagingSenderId: "826546698398",
  appId: "1:826546698398:web:9a350e2b3282eaf974e38f"
  );
}
// TODO Implement this library.
