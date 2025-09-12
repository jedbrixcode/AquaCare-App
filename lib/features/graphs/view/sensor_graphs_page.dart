import 'package:flutter/material.dart';

class SensorGraphsPage extends StatelessWidget {
  const SensorGraphsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Graphs'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Center(
        child: Text('Graphs page scaffold'),
      ),
    );
  }
}


