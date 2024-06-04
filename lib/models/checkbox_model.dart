import 'conversation.dart';

class CheckBoxModel extends Conversation {
  bool isChecked;
  dynamic next;

  CheckBoxModel(
      {required String id,
        required String content,
        required this.isChecked,
        required this.next})
      : super(id: id, content: content);
}