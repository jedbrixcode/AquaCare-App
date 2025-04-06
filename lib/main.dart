import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:aquacare_v5/pages/autofeed_page.dart';
import 'package:aquacare_v5/pages/autolight_page.dart';
import 'package:aquacare_v5/pages/home_page.dart';
import 'package:aquacare_v5/pages/landing_page.dart';
import 'package:aquacare_v5/pages/phlevel_page.dart';
import 'package:aquacare_v5/pages/temperature_page.dart';
import 'package:aquacare_v5/pages/waterquality_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/landing',
      debugShowCheckedModeBanner: false,
      routes: {
        '/landing': (context) => LandingPage(),
        '/homepage': (context) => HomePage(),
        '/temperature': (context) => TemperaturePage(),
        '/waterquality': (context) => WaterQualityPage(),
        '/food': (context) => AutoFeedingPage(),
        '/light': (context) => AutoLightPage(),
        '/phlevel': (context) => PhlevelPage(),
      },
    );
  }
}
