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
import 'bnb_custom_painter.dart';
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
                          builder: (context) => const DiaryListScreen()),
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
                  icon: Icon(Icons.settings,
                      color: currentIndex == 2 ? Colors.black54 : Colors.white),
                ),
                IconButton(
                  onPressed: () async {
                    _onIconPressed(3);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("로그아웃"),
                          content: Text("정말 로그아웃 하시겠습니까?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                // 로그아웃 코드 실행
                                _onIconPressed(0);
                                try {
                                  var code = await KakaoLogin().logout();
                                  await FirebaseAuth.instance.signOut();

                                  debugPrint('카카오 로그아웃 성공: $code');
                                } catch (e) {
                                  // print('카카오 로그아웃 실패: $e');
                                }
                                try {
                                  await GoogleSignIn().signOut();
                                  debugPrint('구글 로그아웃 성공');
                                } catch (e) {
                                  debugPrint('구글 로그아웃 실패: $e');
                                }
                                Navigator.pop(context); // 다이얼로그 닫기
                              },
                              child: Text("예"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // 다이얼로그 닫기
                              },
                              child: Text("아니오"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.logout_outlined,
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
