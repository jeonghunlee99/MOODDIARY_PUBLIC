import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DiaryViewModel {
  Future<bool> checkIfDiaryExists(DateTime date) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/${date.year}.json';
    File diaryFile = File(filePath);

    if (await diaryFile.exists()) {
      String existingContent = await diaryFile.readAsString();
      List<Map<String, dynamic>> allDiaries =
      List<Map<String, dynamic>>.from(jsonDecode(existingContent));
      String currentDate =
          '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      int existingDiaryIndex =
      allDiaries.indexWhere((diary) => diary['date'] == currentDate);

      return existingDiaryIndex != -1;
    } else {
      return false;
    }
  }
  Future<int> getDiaryCountForYear(int year) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$year.json';
    File diaryFile = File(filePath);
    List<Map<String, dynamic>> allDiaries = [];
    if (await diaryFile.exists()) {
      String existingContent = await diaryFile.readAsString();
      allDiaries = List<Map<String, dynamic>>.from(jsonDecode(existingContent));
    }
    return allDiaries.length;
  }

  Future<void> saveDiaries(List<Map<String, dynamic>> allDiaries, int year) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$year.json';
    File diaryFile = File(filePath);
    JsonEncoder encoder = const JsonEncoder.withIndent('    ');
    String diaryJson = encoder.convert(allDiaries);
    await diaryFile.writeAsString(diaryJson);
  }

}
