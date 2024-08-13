import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mooddiary/screen/mood_chart.dart';
import 'package:mooddiary/screen/setting_page.dart';
import 'package:mooddiary/utils/constant.dart';
import 'package:mooddiary/utils/ad_mob_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../api/weather_api.dart';
import '../screen/diary_list_screen.dart';
import '../login/kakao_login.dart';
import '../screen/my_info_scren.dart';
import '../viewmodels/diary_list_viewmodel.dart';


import 'package:mooddiary/screen/chatbot_screen.dart';
import 'dart:io';
import 'login_dialog.dart';

class CustomBottomNavBar extends StatefulWidget {
  final DateTime selectedDate;

  const CustomBottomNavBar({
    super.key,
    required this.selectedDate,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int currentIndex = 0;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  RewardAdManager adManager = RewardAdManager(rewardAdId: rewardAdId);

  Future<bool> checkGoogleLoginStatus() async {
    try {
      bool isSignedIn = await googleSignIn.isSignedIn();
      return isSignedIn;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkKakaoLoginStatus() async {
    try {
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // adManager.loadAd();
  }

  @override
  void dispose() {
    // adManager.dispose();
    super.dispose();
  }

  DiaryListViewModel viewModel = DiaryListViewModel();

  @override
  Widget build(BuildContext context) {
    var weatherService = Provider.of<WeatherService>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: BNBCustomPainter(),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () async {
                // 여기에 일기 개수를 파악하는 코드를 추가합니다.
                DateTime selectedDate = widget.selectedDate;
                String currentYear = selectedDate.year.toString();

                Directory docDir = await getApplicationDocumentsDirectory();
                String filePath = '${docDir.path}/$currentYear.json';
                File diaryFile = File(filePath);
                List<Map<String, dynamic>> allDiaries = [];
                if (await diaryFile.exists()) {
                  String existingContent = await diaryFile.readAsString();
                  allDiaries = List<Map<String, dynamic>>.from(
                      jsonDecode(existingContent));
                }
                int diaryCount = allDiaries.length;

                if (diaryCount > 1 &&
                    !(await checkKakaoLoginStatus() ||
                        await checkGoogleLoginStatus())) {
                  LoginDialog.showLoginDialog(context, () async {
                    if (context.mounted) {
                      JsonEncoder encoder =
                          const JsonEncoder.withIndent('    ');
                      String diaryJson = encoder.convert(allDiaries);
                      try {
                        await diaryFile.writeAsString(diaryJson);
                      } catch (e) {
                        return;
                      }
                    }
                  }, true);
                } else {
                  String currentDate =
                      '${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                  int existingDiaryIndex = allDiaries
                      .indexWhere((diary) => diary['date'] == currentDate);

                  if (existingDiaryIndex != -1) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:
                              const Text('이미 일기가 작성되어 있습니다. \n다시 작성하시겠습니까?'),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('예'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                adManager.loadAd();
                                adManager.showAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatBotApp(
                                      selectedDate: selectedDate,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ElevatedButton(
                              child: const Text('아니오'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatBotApp(
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartPage(
                          selectedDate: widget.selectedDate,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.bar_chart,
                      color: currentIndex == 0 ? Colors.black54 : Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    _onIconPressed(1);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  DiaryListScreen(viewModel: viewModel)),
                    );
                  },
                  icon: Icon(Icons.list,
                      color: currentIndex == 1 ? Colors.black54 : Colors.white),
                ),
                Container(width: MediaQuery.of(context).size.width * 0.20),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingPage()),
                    );
                    _onIconPressed(2);
                  },
                  icon: Icon(Icons.alarm,
                      color: currentIndex == 2 ? Colors.black54 : Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyInfoScreen()),
                    );
                    _onIconPressed(3);
                  },

                  icon: Icon(Icons.account_circle,
                      color: currentIndex == 3 ? Colors.black54 : Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onIconPressed(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}