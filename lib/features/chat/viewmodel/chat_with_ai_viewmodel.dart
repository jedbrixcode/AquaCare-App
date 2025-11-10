import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/chat/repository/chat_repository.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';
import 'package:aquacare_v5/core/models/chat_message_isar.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageBytes,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final String inputText;
  final bool isSending;
  final String? errorMessage;
  final Uint8List? attachedImage;
  final String? attachedMime;

  const ChatState({
    this.messages = const [],
    this.inputText = '',
    this.isSending = false,
    this.errorMessage,
    this.attachedImage,
    this.attachedMime,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? inputText,
    bool? isSending,
    String? errorMessage,
    Uint8List? attachedImage,
    String? attachedMime,
    bool clearError = false,
    bool clearAttachment = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      inputText: inputText ?? this.inputText,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      attachedImage:
          clearAttachment ? null : (attachedImage ?? this.attachedImage),
      attachedMime:
          clearAttachment ? null : (attachedMime ?? this.attachedMime),
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final ChatRepository _repo;
  ChatViewModel(this._repo) : super(const ChatState()) {
    _loadFromCache();
    _subscribe();
  }

  Future<void> _loadFromCache() async {
    final items = await LocalStorageService.instance.getChatMessages();
    final mapped =
        items
            .map(
              (e) => ChatMessage(
                id: e.messageId,
                text: e.text,
                isUser: e.isUser,
                timestamp: e.timestamp,
                imageBytes:
                    e.imageBytes != null
                        ? Uint8List.fromList(e.imageBytes!)
                        : null,
              ),
            )
            .toList();
    state = state.copyWith(messages: mapped);
  }

  void _subscribe() {
    LocalStorageService.instance.watchChatMessages().listen((items) {
      final mapped =
          items
              .map(
                (e) => ChatMessage(
                  id: e.messageId,
                  text: e.text,
                  isUser: e.isUser,
                  timestamp: e.timestamp,
                  imageBytes:
                      e.imageBytes != null
                          ? Uint8List.fromList(e.imageBytes!)
                          : null,
                ),
              )
              .toList();
      state = state.copyWith(messages: mapped);
    });
  }

  void setInput(String text) {
    state = state.copyWith(inputText: text, clearError: true);
  }

  void attachImage(Uint8List bytes, {String mime = 'image/jpeg'}) {
    state = state.copyWith(
      attachedImage: bytes,
      attachedMime: mime,
      clearError: true,
    );
  }

  void removeAttachment() {
    state = state.copyWith(clearAttachment: true);
  }

  Future<void> clearChatHistory() async {
    state = state.copyWith(messages: []);
    await LocalStorageService.instance.clearChatMessages();

    final databaseRef = FirebaseDatabase.instance.ref();
    await databaseRef.child('chats').remove();
  }

  Future<void> send() async {
    if (state.isSending) return;
    final text = state.inputText.trim();
    final image = state.attachedImage;
    if (text.isEmpty && image == null) return;

    state = state.copyWith(isSending: true, clearError: true);

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageBytes: image,
    );
    state = state.copyWith(messages: [...state.messages, userMsg]);
    await LocalStorageService.instance.addChatMessage(
      ChatMessageIsar()
        ..messageId = userMsg.id
        ..text = userMsg.text
        ..isUser = true
        ..timestamp = userMsg.timestamp
        ..imageBytes = image?.toList(),
    );

    try {
      String aiText;
      if (image != null) {
        final base64Image =
            'data:${state.attachedMime ?? 'image/jpeg'};base64,${base64Encode(image)}';
        aiText = await _repo.askImage(
          text: text.isEmpty ? null : text,
          imageBase64: base64Image,
        );
      } else {
        aiText = await _repo.askText(text: text);
      }

      final aiMsg = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-ai',
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        inputText: '',
        isSending: false,
        clearAttachment: true,
      );
      await LocalStorageService.instance.addChatMessage(
        ChatMessageIsar()
          ..messageId = aiMsg.id
          ..text = aiMsg.text
          ..isUser = false
          ..timestamp = aiMsg.timestamp,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: e.toString());
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatViewModel(repo);
});
