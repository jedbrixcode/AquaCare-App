import 'package:flutter/material.dart';

class WaterQualityPage extends StatefulWidget {
  const WaterQualityPage({super.key});

  @override
  State<WaterQualityPage> createState() => _WaterQualityPageState();
}

class _WaterQualityPageState extends State<WaterQualityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Water Quality"),
        backgroundColor: Colors.blue,
      ),
      body: Center(child: Text("dito mga Water Quali")),
    );
  }
}
