import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aquacare_v5/features/chat/viewmodel/chat_with_ai_viewmodel.dart';

class AIChatPage extends ConsumerStatefulWidget {
  const AIChatPage({super.key});

  @override
  ConsumerState<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends ConsumerState<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    ref
        .read(chatViewModelProvider.notifier)
        .attachImage(bytes, mime: 'image/jpeg');
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    ref
        .read(chatViewModelProvider.notifier)
        .attachImage(bytes, mime: 'image/jpeg');
  }

  Future<void> _send() async {
    await ref.read(chatViewModelProvider.notifier).send();
    if (mounted) {
      _controller.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isUser = message.isUser;
    final title = isUser ? 'User' : 'AquaBot';
    final icon = isUser ? Icons.account_circle : Icons.chat_bubble;
    final backgroundColor = isUser ? Colors.blue : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Title and Icon
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
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Message Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.memory(message.imageBytes!, width: 220),
                    ),
                  SelectableText(
                    message.text.isEmpty ? '(image)' : message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatViewModelProvider);

    if (_controller.text != chat.inputText) {
      _controller.text = chat.inputText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
      if (chat.errorMessage != null && chat.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(chat.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with AquaBot"),
        backgroundColor: const Color.fromARGB(255, 8, 165, 146),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
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
              if (confirm == true) {
                ref.read(chatViewModelProvider.notifier).clearChatHistory();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                reverse: true,
                itemCount: chat.messages.length + (chat.isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && chat.isSending) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final messageIndex = chat.isSending ? index - 1 : index;
                  return _buildChatMessage(
                    chat.messages[chat.messages.length - 1 - messageIndex],
                  );
                },
              ),
            ),
            if (chat.attachedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.memory(
                      chat.attachedImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Attached image')),
                    IconButton(
                      onPressed:
                          () =>
                              ref
                                  .read(chatViewModelProvider.notifier)
                                  .removeAttachment(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // Left image buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_camera),
                        onPressed: chat.isSending ? null : _pickFromCamera,
                        tooltip: 'Capture fish photo',
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: chat.isSending ? null : _pickFromGallery,
                        tooltip: 'Upload fish photo',
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged:
                          (v) => ref
                              .read(chatViewModelProvider.notifier)
                              .setInput(v),
                      decoration: const InputDecoration(
                        hintText: "Ask me anything about aquatic life...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 28),
                    onPressed: chat.isSending ? null : _send,
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
      body: const Center(child: Text('Chat feature coming soon')),
    );
  }
}
