import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/notification.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isSwitched = false;
  String timeToDisplay = "시간이 설정되지 않았습니다.";

  @override
  void initState() {
    debugPrint('Initializing notifications...');
    FlutterLocalNotification.init();
    super.initState();
  }

  void _requestPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {

      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('알림 권한 요청'),
            content: const Text('알림 기능을 사용하기 위해서는 알림 권한이 필요합니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('설정'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
              TextButton(
                child: const Text('취소'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }


  void _showNotificationAtTime() async {

     _requestPermissions();


    final TimeOfDay? selectedTime = await showTimePicker(
      barrierDismissible: false,
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      var selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );


      if (selectedDateTime.isBefore(now)) {
        selectedDateTime = selectedDateTime.add(const Duration(days: 1));
      }

      debugPrint('Scheduling notification for $selectedDateTime');
      FlutterLocalNotification.showNotification(selectedDateTime);

      final period = selectedTime.period == DayPeriod.am ? "AM" : "PM";
      final hour = selectedTime.hourOfPeriod;
      final minute = selectedTime.minute.toString().padLeft(2, '0');

      setState(() {
        timeToDisplay = "$hour:$minute $period";
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
        timeToDisplay = "알람이 설정되어 있지 않습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.brown[400],
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "일기 알림 받기",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        timeToDisplay, // 설정된 시간 표시
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          if (isSwitched) {
                            _showNotificationAtTime();
                          } else {
                            timeToDisplay = "알람이 설정되어 있지 않습니다.";
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}