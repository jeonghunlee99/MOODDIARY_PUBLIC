import 'package:flutter/material.dart';

class GSDatePicker extends StatefulWidget {
  final String tag;
  final String title;
  final DateTime? selectedDate;
  final Function(DateTime) onDateChanged;

  const GSDatePicker({super.key,
    required this.tag,
    required this.title,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  GSDatePickerState createState() => GSDatePickerState();
}

class GSDatePickerState extends State<GSDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    )) ?? _selectedDate;

    if (picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateChanged(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 11),
        ),
        const SizedBox(height: 10,),
        InkWell(
          onTap: () {
            _selectDate(context);
          },
          child: InputDecorator(
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: const Color(0xfff5f5f5)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
