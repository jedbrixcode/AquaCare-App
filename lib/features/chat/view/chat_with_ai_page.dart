import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aquacare_v5/features/chat/viewmodel/chat_with_ai_viewmodel.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    final compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 800,
      minHeight: 800,
      quality: 60,
    );

    if (compressed == null) return;

    ref
        .read(chatViewModelProvider.notifier)
        .attachImage(Uint8List.fromList(compressed), mime: 'image/jpeg');
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
    if (_controller.text.trim().isEmpty) return;

    // Send message
    await ref.read(chatViewModelProvider.notifier).send();
    ref.read(chatViewModelProvider.notifier).setInput('');
    _controller.clear();
    // Scroll to the bottom after sending message
    await Future.delayed(const Duration(milliseconds: 200));
    if (_scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isUser = message.isUser;
    final title = isUser ? 'User' : 'AquaBot';
    final icon = isUser ? Icons.account_circle : Icons.smart_toy_rounded;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isUser
            ? (isDarkMode
                ? const Color.fromARGB(255, 21, 101, 192)
                : Colors.blue)
            : (isDarkMode
                ? const Color.fromARGB(255, 0, 77, 64)
                : const Color.fromARGB(255, 0, 121, 107));

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
                vertical: 1.0,
                horizontal: 10.0,
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

    // 🔧 Scroll to bottom after frame build
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

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with AquaBot"),
        backgroundColor:
            isDark
                ? Color.fromARGB(255, 0, 105, 93)
                : Color.fromARGB(255, 0, 173, 153),
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

      // MAIN CHAT BODY
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowIndicator();
                      return true;
                    },
                    child: ListView.builder(
                      controller: _scroll,
                      reverse: false,
                      itemCount:
                          chat.messages.length + (chat.isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show the waveDots loader at the BOTTOM
                        if (index == chat.messages.length && chat.isSending) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Center(
                                child: LoadingAnimationWidget.waveDots(
                                  color: Colors.teal,
                                  size: 50,
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildChatMessage(chat.messages[index]);
                      },
                    ),
                  ),
                ),

                // 🔧 Image preview if attached
                if (chat.attachedImage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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

                // INPUT AREA
                Padding(
                  padding: EdgeInsets.only(
                    top: ResponsiveHelper.verticalPadding(context) / 2,
                    bottom: ResponsiveHelper.verticalPadding(context) / 2,
                    left: ResponsiveHelper.horizontalPadding(context) / 16,
                    right: ResponsiveHelper.horizontalPadding(context) / 16,
                  ),
                  child: Row(
                    children: [
                      // Camera & Gallery
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_camera, size: 28),
                            onPressed: chat.isSending ? null : _pickFromCamera,
                            tooltip: 'Capture fish photo',
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_library, size: 28),
                            onPressed: chat.isSending ? null : _pickFromGallery,
                            tooltip: 'Upload fish photo',
                          ),
                        ],
                      ),
                      SizedBox(
                        width: ResponsiveHelper.horizontalPadding(context) / 16,
                      ),

                      // Text input
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

                      // Send Button
                      IconButton(
                        icon: Icon(Icons.send, size: 28),
                        onPressed:
                            chat.isSending
                                ? null
                                : () async {
                                  await _send();
                                  _controller.clear();
                                  ref
                                      .read(chatViewModelProvider.notifier)
                                      .setInput('');
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                  if (_scroll.hasClients) {
                                    _scroll.jumpTo(
                                      _scroll.position.maxScrollExtent,
                                    );
                                  }
                                },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
