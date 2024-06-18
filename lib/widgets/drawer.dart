import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

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
          MyDrawerItem(title: '공지사항', onTap: () {}),
          MyDrawerItem(title: '오류문의', onTap: () {}),
          MyDrawerItem(title: '업무제휴 문의', onTap: () {}),
          MyDrawerItem(title: '개인정보취급방침', onTap: () {
            launch("https://sites.google.com/view/myfoodrecipe/%ED%99%88");
          }),
          MyDrawerItem(title: '이용악관', onTap: () {}),
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