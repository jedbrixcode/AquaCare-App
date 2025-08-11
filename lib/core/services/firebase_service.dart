import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aquacare_v5/firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }

  static DatabaseReference db() {
    return FirebaseDatabase.instance.ref();
  }

  static FirebaseMessaging messaging() {
    return FirebaseMessaging.instance;
  }
}
