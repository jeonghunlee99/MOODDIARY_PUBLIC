import '../models/checkbox_model.dart';
import '../models/conversation.dart';
import '../models/sentence_model.dart';

class ChatLogic {
  static void handleCheckBoxSelection(
      CheckBoxModel checkBox, List<Conversation> conversations, List<String> selectedOptions) {
    selectedOptions.add(checkBox.content);
    checkBox.isChecked = true;
    int currentIndex = conversations.indexOf(checkBox);
    conversations.insert(
        currentIndex + 1,
        SentenceModel(
            id: 'user',
            content: checkBox.content,
            isUser: true));
    conversations.removeWhere((c) => c is CheckBoxModel);

    if (checkBox.next != null) {
      conversations.add(SentenceModel(
          id: 'reply',
          content: checkBox.next['reply'],
          isUser: false));
      checkBox.next['option'].forEach((option) {
        if (option is String) {
          conversations.add(CheckBoxModel(
            id: option,
            content: option,
            isChecked: false,
            next: null,
          ));
        } else {
          conversations.add(CheckBoxModel(
            id: option['mood'],
            content: option['mood'],
            isChecked: false,
            next: option,
          ));
        }
      });
    }
  }
}
