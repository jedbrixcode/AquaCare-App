import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:aquacare_v5/core/config/backend_config.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool isLoading = false; // To show loading indicator
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadMessagesFromPrefs(); // load chat on startup
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('chat_messages');
    }
  }

  Future<void> saveMessagesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedMessages =
        _messages.map((msg) => json.encode(msg)).toList();
    await prefs.setStringList('chat_messages', encodedMessages);
  }

  Future<void> loadMessagesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedMessages = prefs.getStringList('chat_messages');
    if (encodedMessages != null) {
      setState(() {
        _messages =
            encodedMessages
                .map((msg) => Map<String, String>.from(json.decode(msg)))
                .toList();
      });
    }
  }

  // Function to send a question to the Flask backend and get the AI's response
  Future<void> sendMessage() async {
    String userMessage = _controller.text;
    if (userMessage.isEmpty && _selectedImage == null) return;

    setState(() {
      _messages.add({"role": "user", "message": userMessage});
      isLoading = true; // Show loading indicator
    });
    await saveMessagesToPrefs();

    _controller.clear();

    http.Response response;
    if (_selectedImage != null) {
      final request = http.MultipartRequest(
        'POST',
        BackendConfig.url('ask_image'),
      );
      if (userMessage.isNotEmpty) {
        request.fields['question'] = userMessage;
      }
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } else {
      response = await http.post(
        BackendConfig.url('ask'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"question": userMessage}),
      );
    }

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      String aiMessage = responseBody['AI_Response'];
      setState(() {
        _messages.add({"role": "ai", "message": aiMessage});
        isLoading = false; // Hide loading indicator
        _selectedImage = null;
      });
    } else {
      setState(() {
        _messages.add({"role": "ai", "message": "Oops, something went wrong!"});
        isLoading = false; // Hide loading indicator
      });
    }
    await saveMessagesToPrefs();
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _captureWithCamera() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Display messages in the chat
  Widget buildChatMessage(Map<String, String> message) {
    bool isUserMessage = message['role'] == 'user';
    String title = isUserMessage ? 'User' : 'AquaBot';
    IconData icon = isUserMessage ? Icons.account_circle : Icons.chat_bubble;
    Color backgroundColor = isUserMessage ? Colors.blue : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Title and Icon (at the top of the message)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Message Box (chat bubble)
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message['message'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loading indicator for the AI response
  Widget buildLoadingIndicator() {
    return isLoading
        ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        )
        : SizedBox.shrink(); // Empty widget when not loading
  }

  @override
  void dispose() {
    // Dispose properly when the app is terminated
    WidgetsBinding.instance.removeObserver(this);
    saveMessagesToPrefs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with AquaBot"),
        backgroundColor: const Color.fromARGB(255, 8, 165, 146),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Delete Chat History?"),
                      content: const Text(
                        "This will remove all messages permanently.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirmDelete == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('chat_messages');
                setState(() {
                  _messages.clear();
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Use Expanded for the chat area to allow scrolling
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return buildLoadingIndicator();
                  }
                  return buildChatMessage(_messages[_messages.length - index]);
                },
              ),
            ),
            // Chat input and send button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
              child: Row(
                children: [
                  // Left image buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_camera),
                        onPressed: _captureWithCamera,
                        tooltip: 'Capture fish photo',
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: _pickFromGallery,
                        tooltip: 'Upload fish photo',
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask me anything about aquatic life...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 28),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
