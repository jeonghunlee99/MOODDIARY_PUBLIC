import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDialog {
  static Future<void> showProfileDialog(BuildContext context, User user) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('realusers').doc(user.uid).get();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('나의 프로필'),
            content: userDoc.exists
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('이름'),
                  subtitle: Text(userDoc['name'] ?? '정보 없음'),
                ),
                ListTile(
                  title: Text('이메일'),
                  subtitle: Text(user.email ?? '정보 없음'),
                ),
                ListTile(
                  title: Text('성별'),
                  subtitle: Text(userDoc['sex'] ?? '정보 없음'),
                ),
                ListTile(
                  title: Text('생일'),
                  subtitle: Text(_formatBirthday(userDoc['birth']) ?? '정보 없음'),
                ),
              ],
            )
                : Text('프로필 정보를 찾을 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('닫기'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showEditProfileDialog(context, user, userDoc);
                },
                child: const Text('수정'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('프로필 정보를 불러오는 중 오류 발생: $e');
    }
  }

  static String? _formatBirthday(Timestamp? timestamp) {
    if (timestamp == null) return null;
    DateTime date = timestamp.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static Future<void> showEditProfileDialog(BuildContext context, User user, DocumentSnapshot userDoc) async {
    final _nameController = TextEditingController(text: userDoc['name']);
    final _sexController = TextEditingController(text: userDoc['sex']);
    final _birthController = TextEditingController(text: _formatBirthday(userDoc['birth']));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: _sexController,
                decoration: InputDecoration(labelText: '성별'),
              ),
              TextField(
                controller: _birthController,
                decoration: InputDecoration(labelText: '생일 (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await _updateUserProfile(user, _nameController.text, _sexController.text, _birthController.text);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _updateUserProfile(User user, String name, String sex, String birth) async {
    try {
      DateTime birthDate = DateTime.parse(birth);
      await FirebaseFirestore.instance.collection('realusers').doc(user.uid).update({
        'name': name,
        'sex': sex,
        'birth': Timestamp.fromDate(birthDate),
      });
      debugPrint('프로필 업데이트 성공');
    } catch (e) {
      debugPrint('프로필 업데이트 실패: $e');
    }
  }
}
