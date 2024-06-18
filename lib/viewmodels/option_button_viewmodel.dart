import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'image_path_provider.dart';

class DiaryRepository {
  Future<void> saveDiary(DateTime selectedDate, List<String> selectedOptions, String diaryContent, String? imagePath) async {

      String currentYear = selectedDate.year.toString();
      String currentDate = '${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      Directory docDir = await getApplicationDocumentsDirectory();
      String filePath = '${docDir.path}/$currentYear.json';
      File diaryFile = File(filePath);

      var diaryData = [
        {
          'date': currentDate,
          'mainEmotion': selectedOptions[0],
          'subEmotion': selectedOptions[1],
          'time': selectedOptions[2],
          'place': selectedOptions[3],
          'reason': selectedOptions[4],
          'diaryContent': diaryContent,
          'imagePath': imagePath,
        }
      ];
      List<Map<String, dynamic>> allDiaries = [];
      if (await diaryFile.exists()) {
        String existingContent = await diaryFile.readAsString();
        allDiaries = List<Map<String, dynamic>>.from(jsonDecode(existingContent));

        int existingDiaryIndex = allDiaries.indexWhere((diary) => diary['date'] == currentDate);
        if (existingDiaryIndex != -1) {
          allDiaries[existingDiaryIndex] = diaryData[0];
        } else {
          allDiaries.addAll(diaryData);
        }
      } else {
        allDiaries.addAll(diaryData);
      }
      allDiaries.sort((a, b) {
        DateTime dateA = DateTime.parse("$currentYear-${a['date']}");
        DateTime dateB = DateTime.parse("$currentYear-${b['date']}");
        return dateA.compareTo(dateB);
      });

      JsonEncoder encoder = const JsonEncoder.withIndent('    ');
      String diaryJson = encoder.convert(allDiaries);
      await diaryFile.writeAsString(diaryJson);
    }



  Future<void> noContentSaveDiary(DateTime selectedDate, List<String> selectedOptions, String? imagePath) async {

      String currentYear = selectedDate.year.toString();
      String currentDate = '${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      Directory docDir = await getApplicationDocumentsDirectory();
      String filePath = '${docDir.path}/$currentYear.json';
      File diaryFile = File(filePath);

      var diaryData = [
        {
          'date': currentDate,
          'mainEmotion': selectedOptions[0],
          'subEmotion': selectedOptions[1],
          'time': selectedOptions[2],
          'place': selectedOptions[3],
          'reason': selectedOptions[4],
          'imagePath': imagePath,
        }
      ];
      List<Map<String, dynamic>> allDiaries = [];
      if (await diaryFile.exists()) {
        String existingContent = await diaryFile.readAsString();
        allDiaries = List<Map<String, dynamic>>.from(jsonDecode(existingContent));

        int existingDiaryIndex = allDiaries.indexWhere((diary) => diary['date'] == currentDate);
        if (existingDiaryIndex != -1) {
          allDiaries[existingDiaryIndex] = diaryData[0];
        } else {
          allDiaries.addAll(diaryData);
        }
      } else {
        allDiaries.addAll(diaryData);
      }
      allDiaries.sort((a, b) {
        DateTime dateA = DateTime.parse("$currentYear-${a['date']}");
        DateTime dateB = DateTime.parse("$currentYear-${b['date']}");
        return dateA.compareTo(dateB);
      });

      JsonEncoder encoder = const JsonEncoder.withIndent('    ');
      String diaryJson = encoder.convert(allDiaries);
      await diaryFile.writeAsString(diaryJson);
    }
  }



class ImageHandler {
  String? _selectedImagePath;

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImagePath = image.path;
      debugPrint('$_selectedImagePath');
      Provider.of<ImagePathProvider>(context, listen: false).imagePath = _selectedImagePath!;
    } else {
      _selectedImagePath = null;
      Provider.of<ImagePathProvider>(context, listen: false).imagePath = null;
    }
  }

  Future<void> saveImage(String imagePath, DateTime selectedDate) async {
    final File imageFile = File(imagePath);
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    final String fileName =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    final File newImageFile = await imageFile.copy('$path/$fileName.png');

    _selectedImagePath = newImageFile.path;
    debugPrint('Saved image path: $_selectedImagePath');
  }
}

