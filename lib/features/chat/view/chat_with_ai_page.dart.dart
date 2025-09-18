import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aquacare_v5/features/chat/viewmodel/chat_with_ai_viewmodel.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

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
        .attachImage(bytes as Uint8List, mime: 'image/jpeg');
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
        .attachImage(bytes as Uint8List, mime: 'image/jpeg');
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

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatViewModelProvider);

    if (_controller.text != chat.inputText) {
      _controller.text = chat.inputText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    final padding = ResponsiveHelper.horizontalPadding(context);

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
      appBar: AppBar(title: const Text('Chat with AI')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                itemCount: chat.messages.length,
                itemBuilder: (context, index) {
                  final m = chat.messages[index];
                  final align =
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft;
                  final color = m.isUser ? Colors.blue[100] : Colors.grey[300];
                  return Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.imageBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.memory(m.imageBytes!, width: 220),
                            ),
                          SelectableText(m.text.isEmpty ? '(image)' : m.text),
                        ],
                      ),
                    ),
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
            Row(
              children: [
                IconButton(
                  tooltip: 'Camera',
                  onPressed: chat.isSending ? null : _pickFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
                IconButton(
                  tooltip: 'Gallery',
                  onPressed: chat.isSending ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_outlined),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged:
                        (v) => ref
                            .read(chatViewModelProvider.notifier)
                            .setInput(v),
                    decoration: const InputDecoration(
                      hintText: 'Ask Aquabot...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Send',
                  onPressed: chat.isSending ? null : _send,
                  icon:
                      chat.isSending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                ),
              ],
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
