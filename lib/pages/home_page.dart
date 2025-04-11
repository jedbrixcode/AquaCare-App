import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aquarium"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue[200],
        toolbarHeight: 75,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, "TEMPERATURE", '/temperature'),
              _buildButton(context, "pH LEVEL", '/phlevel'),
              _buildButton(context, "WATER TURBIDITY", '/waterturbidity'),
              _buildButton(context, "AUTOMATED FEEDING", '/food'),
              _buildButton(context, "AUTOMATED LIGHTS", '/light'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, String route) {
    return SizedBox(
      width: double.infinity, // Full width
      height: 70, // Fixed height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ), // Standard text size
          //backgroundColor: Colors.blue[300], // Consistent button color
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(text),
      ),
    );
  }
}
