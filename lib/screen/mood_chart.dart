import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mooddiary/widgets/indicator.dart';
import 'package:path_provider/path_provider.dart';

class ChartPage extends StatefulWidget {
  final DateTime selectedDate;

  const ChartPage({
    super.key,
    required this.selectedDate,
  });

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  String _earliestDate = "";
  List<BarChartGroupData> barChartData = [];
  int _totalEntries = 0;
  List<PieChartSectionData> pieChartData = [];
  String selectedEmotionGroup = '행복한 기분'; // 초기 감정 그룹 설정
  final emotionGroups = {
    '행복한 기분': ['행복', '기쁨'],
    '슬픈 기분': ['슬픔', '우울'],
    '최근 2주 기분': []

  };

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  void _loadJson() async {
    DateTime selectedDate = widget.selectedDate;
    String currentYear = selectedDate.year.toString();

    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$currentYear.json';
    File diaryFile = File(filePath);

    if (await diaryFile.exists()) {
      String content = await diaryFile.readAsString();
      List<dynamic> jsonContent = jsonDecode(content);

      List<String> allDates = jsonContent.map((item) => item['date'].toString()).toList();
      allDates.sort();

      String earliestDate = allDates.first;
      int totalEntries = jsonContent.length;
      List<PieChartSectionData> data;

      if (selectedEmotionGroup == '최근 2주 기분') {
        data = await createRecentEmotionPieChartData(filePath);
      } else {
        data = await createPieChartData(filePath);
      }
      pieChartData = await createPieChartData(filePath);

      setState(() {
        _earliestDate = earliestDate;
        _totalEntries = totalEntries;
        pieChartData = data;
      });
    } else {
      debugPrint('There is no file');
    }
  }

  Future<List<PieChartSectionData>> createPieChartData(
      String filePath,
      ) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();
    final data = jsonDecode(jsonData) as List;


    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final filteredData = data.where((item) {
      final date = DateTime.parse('2024-' + item['date']);
      return date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0;
    });

    // 특정 주요 감정 그룹 필터링
    final filteredByEmotionGroup = filteredData.where((item) =>
        emotionGroups[selectedEmotionGroup]!
            .contains(item['mainEmotion'])); // selectedEmotionGroup 사용

    final goodMoodsByTime = <String, int>{};
    for (var item in filteredByEmotionGroup) {
      final timeRange = item['time'];

      goodMoodsByTime[timeRange] = goodMoodsByTime.containsKey(timeRange)
          ? goodMoodsByTime[timeRange]! + 1
          : 1;
    }

    // PieChartSectionData 객체 생성
    final pieChartData = <PieChartSectionData>[];
    for (var entry in goodMoodsByTime.entries) {
      pieChartData.add(PieChartSectionData(
        value: entry.value.toDouble(),
        color: _getColor(entry.key),
        title: entry.key,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        badgeWidget: Text('${entry.value}'), // 이 부분을 추가
        badgePositionPercentageOffset: .5,
        showTitle: false,
      ));
    }

    return pieChartData;
  }

  Future<List<PieChartSectionData>> createRecentEmotionPieChartData(
      String filePath,
      ) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();
    final data = jsonDecode(jsonData) as List;


    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final filteredData = data.where((item) {
      final dateParts = item['date'].split('-');
      final date = DateTime.parse(
          '2024-${dateParts[0]}-${dateParts[1]}');
      return date.isAfter(twoWeeksAgo);
    });

    // 감정 집계
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
          child: Text(
            '${entry.value}',
          ),
        ),
        badgePositionPercentageOffset: .50,

        showTitle: false,
      ));
    }

    return pieChartData;
  }

  Color _getColor(String key) {
    if (selectedEmotionGroup == '최근 2주 기분') {
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
    } else {
      switch (key) {
        case '06~12시':
          return Colors.blue;
        case '12~18시':
          return Colors.green;
        case '18~24시':
          return Colors.yellow;
        case '00~06시':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: const Text('Statistics'),
        backgroundColor: Colors.brown[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('일기 쓰기 시작한 날짜: $_earliestDate',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container( // 두 번째 챗버블
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('일기 쓴 날짜 : $_totalEntries',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 20, color: Colors.grey[300],),
              DropdownButton<String>(
                value: selectedEmotionGroup,
                items: emotionGroups.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEmotionGroup = newValue!;
                    _loadJson();
                  });
                },
              ),
              SizedBox(
                height: 300,
                width: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 100,
                    sections: pieChartData,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  children: pieChartData.map((data) {
                    return Indicator(
                      color: data.color,
                      text: data.title,
                      isSquare: true,
                    );
                  }).toList(),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}