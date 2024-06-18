import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationModel _notificationModel = NotificationModel(dateTime: DateTime.now(), isEnabled: false);

  NotificationModel get notificationModel => _notificationModel;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  NotificationViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return; // 이미 초기화된 경우 재초기화 방지
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('drawable/icon1');

    try {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: androidInitializationSettings),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  Future<void> showNotification(DateTime scheduledNotificationDateTime) async {
    if (!_isInitialized) {
      debugPrint('Notifications plugin not initialized');
      return;
    }

    if (_notificationModel.isEnabled && _notificationModel.dateTime == scheduledNotificationDateTime) {
      debugPrint('Notification already set for this time');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'MOOD DIARY',
        '일기를 쓸 시간이에요~',
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      _notificationModel = NotificationModel(dateTime: scheduledNotificationDateTime, isEnabled: true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(0);
      _notificationModel = NotificationModel(dateTime: DateTime.now(), isEnabled: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<PermissionStatus> requestNotificationPermissions() async {
    try {
      final status = await Permission.notification.request();
      return status;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return PermissionStatus.denied;
    }
  }
}
