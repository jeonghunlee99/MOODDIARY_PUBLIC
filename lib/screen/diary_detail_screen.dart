import 'package:flutter/material.dart';

class DiaryDetailPage extends StatelessWidget {
  final Map<String, String> diaryData;

  const DiaryDetailPage({
    Key? key,
    required this.diaryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Diary'),
        backgroundColor: Colors.brown[400],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: SingleChildScrollView(
            child: AspectRatio(
              aspectRatio: 0.6, // 가로 세로 비율 조정
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // 원 모양의 모서리 설정
                  border: Border.all(
                    // 테두리 추가
                    color: Colors.brown[400]!, // 테두리 색상
                    width: 4, // 테두리 두께
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown[400]!, // 그림자 색상
                      spreadRadius: 8, // 그림자의 넓이
                      blurRadius: 8, // 그림자의 흐림 정도
                      offset: Offset(0, 3), // 그림자 위치 조정
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Today Diary',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[400],
                          ),
                        ),
                      ),
                      Divider(
                        height: 0,
                        color: Colors.grey[300],
                        thickness: 2,
                      ),
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '메인 감정: ${diaryData['mainEmotion']}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                            Text(
                              '세부 감정: ${diaryData['subEmotion']}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                            Text(
                              '시간대: ${diaryData['time']}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                            Text(
                              '장소: ${diaryData['place']}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                            Text(
                              '이유: ${diaryData['reason']}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                            SizedBox(height: 24.0),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Card(
                                  elevation: 0, // 그림자 제거
                                  color: Colors.grey[200], // 회색 배경
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      diaryData['diaryContent']!,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
