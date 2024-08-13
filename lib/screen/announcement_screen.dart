import 'package:flutter/material.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final List<Map<String, String>> announcements = [
    {
      'title': '안녕하세요!',
      'description': '금일의 공지사항에 대해서 알려드리려고 합니다.',
      'details': '1. 공지사항 페이지를 개설하였습니다.\n'
          '2. 공지사항은 업데이트시 공지가 올라갈 예정입니다.'
    },
    {
      'title': '공지사항 제목 2',
      'description': '공지사항 설명 2. 공지사항의 간단한 요약 내용을 여기에 작성합니다.',
      'details': '공지사항 상세 내용 2. 여기에 공지사항의 전체 내용을 작성합니다.'
    },
    // 추가 공지사항
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.brown[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(announcements[index]['title'] ?? '제목 없음'),
                subtitle: Text(announcements[index]['description'] ?? '설명 없음'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailScreen(
                        title: announcements[index]['title'] ?? '제목 없음',
                        details: announcements[index]['details'] ?? '내용 없음',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnnouncementDetailScreen extends StatelessWidget {
  final String title;
  final String details;

  const AnnouncementDetailScreen({
    Key? key,
    required this.title,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항"),
        backgroundColor: Colors.brown[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
