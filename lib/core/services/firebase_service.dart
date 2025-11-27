import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aquacare_v5/firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    // Check if Firebase is already initialized using a safer method
    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      return;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }

  static DatabaseReference? db() {
    // Check if Firebase is initialized using a safer method
    if (Firebase.apps.isEmpty) {
      return null; // Firebase not initialized
    }
    return FirebaseDatabase.instance.ref();
  }

  static FirebaseMessaging? messaging() {
    // Check if Firebase is initialized using a safer method
    if (Firebase.apps.isEmpty) {
      return null; // Firebase not initialized
    }
    return FirebaseMessaging.instance;
  }
}
