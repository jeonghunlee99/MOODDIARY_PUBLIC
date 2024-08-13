import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../login/kakao_login.dart';
import '../widgets/login_dialog.dart';
import '../widgets/profiledialog.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({Key? key}) : super(key: key);

  @override
  _MyInfoScreenState createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      var code = await KakaoLogin().logout();
      await FirebaseAuth.instance.signOut();
      debugPrint('카카오 로그아웃 성공: $code');
    } catch (e) {
      debugPrint('카카오 로그아웃 실패: $e');
    }
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      debugPrint('구글 로그아웃 성공');
    } catch (e) {
      debugPrint('구글 로그아웃 실패: $e');
    }
    Navigator.pop(context); // 다이얼로그 닫기
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("로그아웃"),
          content: const Text("정말 로그아웃 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _handleLogout(context);
              },
              child: const Text("예"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text("아니오"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Info'),
        backgroundColor: Colors.brown[400],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle, size: 30),
            title: Text('프로필 보기', style: TextStyle(fontSize: 18)),
            onTap: () {
              if (_user != null) {
                ProfileDialog.showProfileDialog(context, _user!);
              } else {
                // 사용자에게 로그인 요청 또는 오류 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인이 필요합니다.')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, size: 30),
            title: Text('설정', style: TextStyle(fontSize: 18)),
            onTap: () {
              // 설정 페이지로 이동 동작 추가
            },
          ),
          ListTile(
            leading: Icon(Icons.info, size: 30),
            title: Text('앱 정보', style: TextStyle(fontSize: 18)),
            onTap: () {
              // 앱 정보 보기 동작 추가
            },
          ),
          if (_user == null) ...[
            ListTile(
              leading: Icon(Icons.login, size: 30),
              title: Text('로그인', style: TextStyle(fontSize: 18)),
              onTap: () {
                LoginDialog.showLoginDialog(context, () {
                  setState(() {
                    _user = FirebaseAuth.instance.currentUser;
                  });
                }, false);
              },
            ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.logout, size: 30),
              title: Text('로그아웃', style: TextStyle(fontSize: 18)),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
