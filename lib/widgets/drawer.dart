import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../screen/announcement_screen.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void _sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[MOOD DIARY 문의하기]',
      recipients: ['zau223@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Failed to send email: $error');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100, // 크기 조절
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown[400],
              ),
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
              child: const Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // 폰트 크기 조절
                ),
              ),
            ),
          ),
          MyDrawerItem(
            title: '공지사항',
            onTap: () {
              // 네비게이션 로직 추가
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementScreen(),
                ),
              );
            },
          ),
          MyDrawerItem(title: '오류문의', onTap: _sendEmail),
          MyDrawerItem(
            title: '개인정보취급방침',
            onTap: () {
              _launchURL("https://sites.google.com/view/mooddiaryprivacy/%ED%99%88");
            },
          ),
          MyDrawerItem(title: '회원탈퇴', onTap: () {}),
        ],
      ),
    );
  }
}

class MyDrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MyDrawerItem({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          const Icon(Icons.keyboard_arrow_right), // 화살표 아이콘
        ],
      ),
      onTap: onTap,
    );
  }
}
