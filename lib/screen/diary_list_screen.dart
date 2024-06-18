import 'dart:io';

import 'package:flutter/material.dart';

import '../models/diary_list_model.dart';
import '../utils/color_table.dart';
import '../viewmodels/diary_list_viewmodel.dart';

class DiaryListScreen extends StatefulWidget {
  final DiaryListViewModel viewModel;

  const DiaryListScreen({Key? key, required this.viewModel}) : super(key: key);

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
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
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
      body: FutureBuilder<void>(
        future: widget.viewModel.readDiaries('2024'),
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
            List<Diary> diaries = widget.viewModel.diaries;
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
                Diary diary = diaries[index]; // 수정된 부분
                return DiaryListItem(diary: diary);
              },
            );
          }
        },
      ),
    );
  }
}

class DiaryListItem extends StatelessWidget {
  final Diary diary;

  const DiaryListItem({Key? key, required this.diary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        diary.diaryContent ?? '작성된 텍스트 일기가 없습니다!',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
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
  }
}