import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ChartViewModel extends ChangeNotifier {


  String _earliestDate = "";
  String _latestDate = "";
  int _totalEntries = 0;
  List<PieChartSectionData> _pieChartData = [];
  String selectedEmotionGroup = '최근 2주 기분';

  String get earliestDate => _earliestDate;
  String get latestDate => _latestDate;
  int get totalEntries => _totalEntries;
  List<PieChartSectionData> get pieChartData => _pieChartData;

  void loadChartData(DateTime selectedDate) async {
    String currentYear = selectedDate.year.toString();
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$currentYear.json';
    File diaryFile = File(filePath);

    if (await diaryFile.exists()) {
      String content = await diaryFile.readAsString();
      List<dynamic> jsonContent = jsonDecode(content);

      // 프린트문 추가
      print('JSON Content: $jsonContent');

      List<String> allDates =
      jsonContent.map((item) => item['date'].toString()).toList();
      allDates.sort();

      String earliestDate = allDates.first;
      String latestDate = allDates.last;
      int totalEntries = jsonContent.length;

      // 프린트문 추가
      print('Earliest Date: $earliestDate');
      print('Latest Date: $latestDate');
      print('Total Entries: $totalEntries');

      List<PieChartSectionData> data =
      await createRecentEmotionPieChartData(filePath);

      // 프린트문 추가
      print('Pie Chart Data: $data');

      _earliestDate = earliestDate;
      _latestDate = latestDate;
      _totalEntries = totalEntries;
      _pieChartData = data;

      notifyListeners();

    } else {
      debugPrint('There is no file');
    }
  }

  Future<List<PieChartSectionData>> createRecentEmotionPieChartData(
      String filePath) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();
    final data = jsonDecode(jsonData) as List;

    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final filteredData = data.where((item) {
      final dateParts = item['date'].split('-');
      final date = DateTime.parse('2024-${dateParts[0]}-${dateParts[1]}');
      return date.isAfter(twoWeeksAgo);
    });

    final emotionCounts = <String, int>{};
    for (var item in filteredData) {
      final emotion = item['mainEmotion'];
      emotionCounts[emotion] =
      emotionCounts.containsKey(emotion) ? emotionCounts[emotion]! + 1 : 1;
    }

    final pieChartData = <PieChartSectionData>[];
    for (var entry in emotionCounts.entries) {
      pieChartData.add(PieChartSectionData(
        value: entry.value.toDouble(),
        color: _getColor(entry.key),
        title: entry.key,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text('${entry.value}'),
        ),
        badgePositionPercentageOffset: .50,
        showTitle: false,
      ));
    }

    return pieChartData;
  }

  Color _getColor(String key) {
    switch (key) {
      case '행복':
        return Colors.blue;
      case '기쁨':
        return Colors.green;
      case '슬픔':
        return Colors.red;
      case '우울':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}