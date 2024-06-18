import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestDialog extends StatefulWidget {
  const PermissionRequestDialog({Key? key}) : super(key: key);

  @override
  PermissionRequestDialogState createState() => PermissionRequestDialogState();
}

class PermissionRequestDialogState extends State<PermissionRequestDialog> {
  @override
  void initState() {
    super.initState();
    _requestPermissions(context);
  }

  void _requestPermissions(BuildContext context) async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        // 권한이 granted된 경우 추가 작업 수행
        Navigator.of(context).pop();
      } else {
        // 권한이 denied된 경우 사용자에게 알림
        // 이미 다이얼로그가 열려있으므로 추가 작업 불필요
      }
    } else {
      // 권한이 이미 granted된 경우 다이얼로그 닫기
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
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
    );
  }
}
