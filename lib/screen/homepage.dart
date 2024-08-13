import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:mooddiary/screen/diary_detail_screen.dart';
import 'package:mooddiary/utils/ad_mob_helper.dart';
import 'package:mooddiary/viewmodels/diary_view_model.dart';
import 'package:mooddiary/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api/weather_api.dart';
import '../widgets/drawer.dart';
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

  final DiaryViewModel _viewModel = DiaryViewModel();

  @override
  void initState() {
    super.initState();
    weatherService = Provider.of<WeatherService>(context, listen: false);
    _adFuture = NativeAdManager(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
    ).createNativeAd();


  }

  @override
  void dispose() {
    _adFuture.then((ad) => ad.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  CalendarWidget(
                    focusedDay: focusedDay,
                    selectedDate: selectedDate,
                    onDaySelected: (selectedDate, focusedDay) async {
                      DateTime now = DateTime.now();
                      if (selectedDate.isAfter(now)) {
                        return;
                      }
                      setState(() {
                        this.selectedDate = selectedDate;
                        this.focusedDay = focusedDay;
                      });
                      if (isSameDay(this.selectedDate, selectedDate)) {
                        this.focusedDay = focusedDay;
                        var diaryData =
                            await _viewModel.loadDiary(selectedDate);
                        if (diaryData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiaryDetailPage(diaryData: diaryData),
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          this.selectedDate = selectedDate;
                          prevSelectedDate = this.selectedDate;
                        });
                      }
                    },
                    viewModel: _viewModel,
                  ),
                ],
              ),
            ),
          ),
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
}

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDate;
  final Function(DateTime, DateTime) onDaySelected;
  final DiaryViewModel viewModel;

  const CalendarWidget({
    Key? key,
    required this.focusedDay,
    required this.selectedDate,
    required this.onDaySelected,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: CalendarFormat.month,
      focusedDay: focusedDay,
      firstDay: DateTime(DateTime.now().year, 1, 1), // 현재 연도의 1월 1일로 설정
      lastDay: DateTime(DateTime.now().year, 12, 31), // 현재 연도의 12월 31일로 설정
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
      onDaySelected: onDaySelected,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          return FutureBuilder<bool>(
            future: viewModel.checkIfDiaryExists(date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData && snapshot.data == true) {
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
    );
  }
}
