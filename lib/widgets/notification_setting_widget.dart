import 'package:flutter/material.dart';

class NotificationSettingWidget extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;
  final String timeToDisplay;

  const NotificationSettingWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.timeToDisplay,
  }) : super(key: key);

  @override
  _NotificationSettingWidgetState createState() =>
      _NotificationSettingWidgetState();
}

class _NotificationSettingWidgetState extends State<NotificationSettingWidget> {
  late bool _isSwitched;

  @override
  void initState() {
    super.initState();
    _isSwitched = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "일기 알림 받기",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.timeToDisplay,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Switch(
              value: _isSwitched,
              onChanged: (value) {
                setState(() {
                  _isSwitched = value;
                  widget.onChanged(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
