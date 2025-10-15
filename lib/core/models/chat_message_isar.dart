import 'package:isar/isar.dart';

part 'chat_message_isar.g.dart';

@collection
class ChatMessageIsar {
  Id id = Isar.autoIncrement;
  late String messageId;
  late String text;
  late bool isUser;
  late DateTime timestamp;

  // Store image bytes if any (optional, can be large)
  List<int>? imageBytes;
}
