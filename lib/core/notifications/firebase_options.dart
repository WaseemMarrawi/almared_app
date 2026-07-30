// Firebase options for the Almared app.
// Values align with:
//   - android/app/google-services.json (com.almared.app)
//   - ios/Runner/GoogleService-Info.plist (com.almared.app)

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class FirebasePlaceholderConfig {
  // Kept for the placeholder-detection guard in FirebaseService.
  static const apiKey = 'A12345678901234567890123456789012345678';
  static const senderId = '000000000000';
  static const projectId = 'placeholder-firebase-project';
  static const storageBucket = 'placeholder-firebase-project.appspot.com';
  static const androidAppId = '1:000000000000:android:1234567890abcdef12345678';
  static const iosAppId = '1:000000000000:ios:1234567890abcdef12345678';
  static const iosBundleId = 'com.almared.app';
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAB-0nnm_33LWw9snBvafpMtzIHRPsE3T0',
    appId: '1:663540830647:android:35e21cf5a4ea499b941832',
    messagingSenderId: '663540830647',
    projectId: 'fanos-40740',
    storageBucket: 'fanos-40740.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVVWnWsBbvZrhjCPLJ9h70plx4Dmzgx-c',
    appId: '1:663540830647:ios:657bc3efe8fc5a0b941832',
    messagingSenderId: '663540830647',
    projectId: 'fanos-40740',
    storageBucket: 'fanos-40740.firebasestorage.app',
    iosBundleId: 'com.almared.app',
  );
}
