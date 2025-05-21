import 'package:flutter/material.dart';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Wait for 6 seconds and then navigate to HomePage
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacementNamed(
        context,
        '/homepage',
      ); // Match route name exactly
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
