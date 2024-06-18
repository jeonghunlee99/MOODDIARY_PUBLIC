import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
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


  Future<Map<String, String>?> loadDiary(DateTime selectedDate) async {
    try {
      String currentYear = selectedDate.year.toString();
      String currentDate =
          '${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'; // 년도를 제외한 월-일 정보
      Directory docDir = await getApplicationDocumentsDirectory();
      String filePath = '${docDir.path}/$currentYear.json';
      File diaryFile = File(filePath);

      if (await diaryFile.exists()) {
        String diaryJson = await diaryFile.readAsString();
        List<Map<String, dynamic>> allDiaries =
        List<Map<String, dynamic>>.from(jsonDecode(diaryJson));

        for (var diaryData in allDiaries) {
          if (diaryData['date'] == currentDate) {
            return {
              'date': currentDate,
              'mainEmotion': diaryData['mainEmotion'] ?? 'Unknown',
              'subEmotion': diaryData['subEmotion'] ?? 'Unknown',
              'time': diaryData['time'] ?? 'Unknown',
              'place': diaryData['place'] ?? 'Unknown',
              'reason': diaryData['reason'] ?? 'Unknown',
              'diaryContent': diaryData['diaryContent'] ?? '아직 작성된 일기가 없습니다.',
            };
          }
        }
      } else {
        debugPrint("No diary file exists for this year.");
      }
    } catch (e) {
      debugPrint("Error loading diary: $e");
    }
    return null;
  }
}

