import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static init() async {

    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('drawable/icon1');


    try {
      await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(android: androidInitializationSettings),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  static Future<void> showNotification(DateTime scheduledNotificationDateTime) async {
    if (!_isInitialized) {
      debugPrint('Notifications plugin not initialized');
      return;
    }

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,

    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'MOOD DIARY',
      '일기를 쓸 시간이에요~',
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
  static Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
