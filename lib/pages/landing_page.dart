import 'package:flutter/material.dart';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:aquacare_v5/features/aquarium/view/aquarium_dashboard_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Wait for 6 seconds and then navigate to AquariumDashboardPage
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AquariumDashboardPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 64, 125, 255),
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Text(
              "Welcome to AquaCare",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Spacer(),
          LoadingAnimationWidget.waveDots(color: Colors.white, size: 40),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
