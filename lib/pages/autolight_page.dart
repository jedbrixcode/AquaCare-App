import 'package:flutter/material.dart';

class AutoLightPage extends StatefulWidget {
  const AutoLightPage({super.key});

  @override
  State<AutoLightPage> createState() => _AutoLightPageState();
}

class _AutoLightPageState extends State<AutoLightPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Light"),
        backgroundColor: Colors.blue,
      ),
      body: Center(child: Text("dito mga auto lights")),
    );
  }
}
