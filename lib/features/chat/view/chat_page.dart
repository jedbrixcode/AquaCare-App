import 'package:flutter/material.dart';

class ChatWithAIPage extends StatelessWidget {
  const ChatWithAIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Center(
        child: Text('Chat feature coming soon'),
      ),
    );
  }
}


