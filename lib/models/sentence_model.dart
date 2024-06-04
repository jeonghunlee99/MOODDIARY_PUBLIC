import 'conversation.dart';

class SentenceModel extends Conversation {
  final bool isUser;

  SentenceModel(
      {required String id, required String content, required this.isUser})
      : super(id: id, content: content);
}