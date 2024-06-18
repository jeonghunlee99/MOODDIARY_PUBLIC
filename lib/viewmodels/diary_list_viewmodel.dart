import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/diary_list_model.dart';

class DiaryListViewModel extends ChangeNotifier {
  List<Diary> _diaries = [];
  List<Diary> get diaries => _diaries;


  Future<void> readDiaries(String year) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$year.json';
    File diaryFile = File(filePath);

    if (await diaryFile.exists()) {
      String existingContent = await diaryFile.readAsString();
      List<dynamic> jsonList = jsonDecode(existingContent);
      _diaries =
          jsonList.map((item) => Diary.fromJson(item)).cast<Diary>().toList();
      notifyListeners();
    } else {
      throw Exception('Diary file does not exist');
    }
  }


}
