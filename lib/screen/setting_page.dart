// views/setting_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/notification_setting_widget.dart';
import '../widgets/request_notification_permission.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _showNotificationAtTime(NotificationViewModel viewModel) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => const PermissionRequestDialog(),
    );

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      var selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (selectedDateTime.isBefore(now)) {
        selectedDateTime = selectedDateTime.add(const Duration(days: 1));
      }

      await viewModel.showNotification(selectedDateTime);
    } else {
      viewModel.cancelNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.brown[400],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              final notificationModel = viewModel.notificationModel;
              final timeOfDay = TimeOfDay.fromDateTime(notificationModel.dateTime);
              final timeToDisplay = notificationModel.isEnabled
                  ? "${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period == DayPeriod.am ? "AM" : "PM"}"
                  : "알람이 설정되어 있지 않습니다.";

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  NotificationSettingWidget(
                    initialValue: notificationModel.isEnabled,
                    onChanged: (value) {
                      if (value) {
                        _showNotificationAtTime(viewModel);
                      } else {
                        viewModel.cancelNotification();
                      }
                    },
                    timeToDisplay: timeToDisplay,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
