import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/mood_chart_view_model.dart';

class ChartPage extends StatefulWidget {
  final DateTime selectedDate;

  const ChartPage({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChartViewModel>(context, listen: false)
        .loadChartData(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.brown[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Consumer<ChartViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DiaryStatistics(
                          title: '일기 쓰기 시작한 날짜',
                          value: viewModel.earliestDate,
                        ),
                        const SizedBox(height: 10.0),
                        DiaryStatistics(
                          title: '일기 쓴 마지막 날짜',
                          value: viewModel.latestDate,
                        ),
                        const SizedBox(height: 10.0),
                        DiaryStatistics(
                          title: '일기 쓴 날',
                          value: viewModel.totalEntries.toString(),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Text(
                    "최근 2주간 저장된 감정",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 100,
                        sections:viewModel.pieChartData,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      children:viewModel.pieChartData.map((data) {
                        return Indicator(
                          color: data.color,
                          text: data.title,
                          isSquare: true,
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.grey[300],
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


class DiaryStatistics extends StatelessWidget {
  final String title;
  final String value;

  const DiaryStatistics({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$title: $value',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  }) : super(key: key);

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
