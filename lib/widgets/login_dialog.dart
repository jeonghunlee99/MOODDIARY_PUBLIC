import 'package:flutter/material.dart';
import '../screen/user_information_write.dart';
import '../login/google_login.dart';
import '../login/kakao_login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginDialog {
  static Future<void> showLoginDialog(BuildContext context, Function onSuccess, bool isNoButton) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그인'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('로그인을 하고 일기를 더 많이 작성해보세요!'),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await GoogleLogin.handleGoogleSignIn(() async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      bool? isFirstLogin = prefs.getBool('isFirstLogin');


                      if (isFirstLogin == null || isFirstLogin == false) {
                        await prefs.setBool('isFirstLogin', true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MultiSectionForm(),
                          ),
                        );
                      } else {
                        await onSuccess(); // 로그인 성공 시 콜백 함수 실행
                        if (isNoButton) {
                          Navigator.pop(context);
                        }
                      }
                    });
                  },
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Image.asset('assets/googlesign.png'),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    bool loginSuccess = await KakaoLogin().login();
                    if (loginSuccess) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      bool? isFirstLogin = prefs.getBool('isFirstLogin');


                      if (isFirstLogin == null || isFirstLogin == false) {
                        await prefs.setBool('isFirstLogin', true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MultiSectionForm(),
                          ),
                        );
                      } else {
                        await onSuccess(); // 로그인 성공 시 콜백 함수 실행
                        if (isNoButton) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Image.asset('assets/kakaotalk.png'),
                  ),
                )
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('object');
    }
  }
}
