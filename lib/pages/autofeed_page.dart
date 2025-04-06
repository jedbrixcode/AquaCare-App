import 'package:flutter/material.dart';

class AutoFeedingPage extends StatefulWidget {
  const AutoFeedingPage({super.key});

  @override
  State<AutoFeedingPage> createState() => _AutoFeedingPageState();
}

class _AutoFeedingPageState extends State<AutoFeedingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Feeding"),
        backgroundColor: Colors.blue,
      ),
      body: Center(child: Text("dito mga pangfeed")),
    );
  }
}
