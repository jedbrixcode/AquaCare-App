import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:aquacare_v5/core/config/backend_config.dart';

class ChatRepository {
  const ChatRepository();

  Future<String> askText({required String text}) async {
    final uri = BackendConfig.url('ask');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'question': text}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return (body['AI_Response'] ?? body['answer'] ?? body['response'] ?? '')
          .toString();
    }
    throw Exception('Chat API error (${response.statusCode})');
  }

  Future<String> askImage({String? text, required String imageBase64}) async {
    final uri = BackendConfig.url('ask');
    final payload = <String, dynamic>{
      if (text != null && text.trim().isNotEmpty) 'question': text,
      'image': imageBase64,
    };
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return (body['AI_Response'] ?? body['answer'] ?? body['response'] ?? '')
          .toString();
    }
    throw Exception('Chat Image API error (${response.statusCode})');
  }
}
