import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase initialization service.
///
/// Android reads `android/app/google-services.json`; iOS reads
/// `ios/Runner/GoogleService-Info.plist`. Keeping Firebase configured from
/// native files means replacing those files is enough when the Firebase project
/// changes.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static bool _isEnabled = false;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  static bool get isEnabled => _isEnabled;

  /// Initialize Firebase before running the app.
  static Future<bool> initialize() async {
    try {
      debugPrint('Initializing Firebase...');

      await Firebase.initializeApp();

      _isEnabled = true;
      debugPrint('Firebase initialized successfully');
      return true;
    } catch (e) {
      _isEnabled = false;
      debugPrint('Firebase initialization error: $e');
      return false;
    }
  }
}
