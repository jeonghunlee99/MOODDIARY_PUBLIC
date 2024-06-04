import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mooddiary/api/login_manager.dart';
import 'package:mooddiary/utils/ad_mob_helper.dart';
import 'package:mooddiary/viewmodels/diary_view_model.dart';
import 'package:mooddiary/widgets/custom_bottom_nav.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api/weather_api.dart';
import 'drawer.dart';
import 'dart:async';
import '../utils/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDate = DateTime.now();
  int currentIndex = 0;
  DateTime? prevSelectedDate;
  late WeatherService weatherService;
  late Future<NativeAd> _adFuture;

  late UserAuthManager _authManager;
  final DiaryViewModel _viewModel = DiaryViewModel();

  @override
  void initState() {
    super.initState();
    weatherService = Provider.of<WeatherService>(context, listen: false);
    _adFuture = NativeAdManager(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
    ).createNativeAd();

    _authManager = UserAuthManager();
    _authManager.init();
  }

  @override
  void dispose() {
    _adFuture.then((ad) => ad.dispose());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var weatherService = Provider.of<WeatherService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MOOD DIARY", style: TextStyle(color: Colors.white)),
        centerTitle: false,
        backgroundColor: Colors.brown[400],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          FutureBuilder<NativeAd>(
            future: _adFuture,
            builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: 32,
                  child: AdWidget(ad: snapshot.data!),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    focusedDay: focusedDay,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2040),
                    availableCalendarFormats: const {
                      CalendarFormat.month: '',
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.brown,
                          width: 2.0,
                        ),
                      ),
                      todayTextStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.brown[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedDayPredicate: (DateTime date) {
                      return isSameDay(date, selectedDate);
                    },
                    onDaySelected: (selectedDate, focusedDay) async {
                      DateTime now = DateTime.now();
                      if (selectedDate.isAfter(now)) {

                        return;
                      }
                      if (isSameDay(this.selectedDate, selectedDate)) {
                        this.focusedDay = focusedDay;
                        await loadDiary(selectedDate);
                      } else {
                        setState(() {
                          this.selectedDate = selectedDate;
                          prevSelectedDate = this.selectedDate;
                        });
                      }
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        return FutureBuilder<bool>(
                          future: _viewModel.checkIfDiaryExists(date),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            } else if (snapshot.hasData &&
                                snapshot.data == true) {
                              return Positioned(
                                bottom: 1,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[400],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CustomBottomNavBar(selectedDate: selectedDate)
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBottomNavBar(
            selectedDate: selectedDate,
          ),
        ],
      ),
    );
  }

  Future<void> loadDiary(DateTime selectedDate) async {
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
            String mainEmotion = diaryData['mainEmotion'] ?? 'Unknown';
            String subEmotion = diaryData['subEmotion'] ?? 'Unknown';
            String time = diaryData['time'] ?? 'Unknown';
            String place = diaryData['place'] ?? 'Unknown';
            String reason = diaryData['reason'] ?? 'Unknown';
            String diaryContent =
                diaryData['diaryContent'] ?? '아직 작성된 일기가 없습니다.';

            Future.microtask(() {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Center(child: Text(currentDate)),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextButton(
                            child: const Text('선택한 감정 보기',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: const Center(
                                          child: Text('선택한 감정',
                                              style:
                                                  TextStyle(fontSize: 24.0))),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('메인 감정: $mainEmotion',
                                              style: const TextStyle(
                                                  fontSize: 20.0)),
                                          Text('세부 감정: $subEmotion',
                                              style: const TextStyle(
                                                  fontSize: 20.0)),
                                          Text('시간대: $time',
                                              style: const TextStyle(
                                                  fontSize: 20.0)),
                                          Text('장소: $place',
                                              style: const TextStyle(
                                                  fontSize: 20.0)),
                                          Text('이유: $reason',
                                              style: const TextStyle(
                                                  fontSize: 20.0)),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('닫기',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ]);
                                },
                              );
                            },
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Text(diaryContent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('확인',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          }
        }
      } else {
        // print("No diary file exists for this year.");
      }
    } catch (e) {
      // print("Error loading diary: $e");
    }
  }
}
