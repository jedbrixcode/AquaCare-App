import 'package:flutter/material.dart';

class PhlevelPage extends StatefulWidget {
  const PhlevelPage({super.key});

  @override
  State<PhlevelPage> createState() => _PhlevelPageState();
}

class _PhlevelPageState extends State<PhlevelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("pH Level"), backgroundColor: Colors.blue),
      body: Center(child: Text("dito mga pH Level")),
    );
  }
}
