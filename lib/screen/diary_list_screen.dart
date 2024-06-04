import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mooddiary/utils/color_table.dart';
import 'package:path_provider/path_provider.dart';

class Diary {
  final String date;
  final String? mainEmotion;
  final String? subEmotion;
  final String? time;
  final String? place;
  final String? reason;
  final String? diaryContent;
  final String? imagePath;

  Diary(
      {required this.date,
      required this.mainEmotion,
      required this.subEmotion,
      required this.time,
      required this.place,
      required this.reason,
      required this.diaryContent,
      required this.imagePath});

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      date: json['date'] as String,
      mainEmotion: json['mainEmotion'] as String?,
      subEmotion: json['subEmotion'] as String?,
      time: json['time'] as String?,
      place: json['place'] as String?,
      reason: json['reason'] as String?,
      diaryContent: json['diaryContent'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  String _searchKeyword = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Diary>> readDiaries(String year) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/$year.json';
    File diaryFile = File(filePath);

    if (await diaryFile.exists()) {
      String existingContent = await diaryFile.readAsString();
      List<dynamic> jsonList = jsonDecode(existingContent);
      List<Diary> diaries =
          jsonList.map((item) => Diary.fromJson(item)).toList();
      return diaries;
    } else {
      throw Exception('Diary file does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.black),
                ),
              )
            : const Text('Diary List'),
        backgroundColor: Colors.brown[400],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchKeyword = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Diary>>(
        future: readDiaries('2024'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Text(
              '아직 작성된 일기가 없습니다!',
              style: TextStyle(
                fontSize: 24.0, // 큰 텍스트 크기
              ),
            );
          } else {
            List<Diary> diaries = snapshot.data!;
            diaries.sort((a, b) {
              var dateA = DateTime.parse('2024-' + a.date);
              var dateB = DateTime.parse('2024-' + b.date);
              return dateB.compareTo(dateA);
            });
            if (_searchKeyword.isNotEmpty) {
              diaries = diaries
                  .where((diary) =>
                      diary.diaryContent
                          ?.toLowerCase()
                          .contains(_searchKeyword.toLowerCase()) ??
                      false)
                  .toList();
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 5 / 2,
                mainAxisSpacing: 15,
              ),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                Diary diary = diaries[index];
                return Card(
                  elevation: 10.0,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: getGradientColor(diary.mainEmotion),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  diary.date,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // 텍스트 색상을 흰색으로 설정
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Text(
                                    diary.diaryContent ?? '작성된 텍스트 일기가 없습니다!',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black, // 텍스트 색상을 흰색으로 설정
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (diary.imagePath != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.file(
                              File(diary.imagePath!),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
