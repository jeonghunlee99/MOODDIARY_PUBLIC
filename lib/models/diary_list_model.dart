class Diary {
  final String date;
  final String? mainEmotion;
  final String? subEmotion;
  final String? time;
  final String? place;
  final String? reason;
  final String? diaryContent;
  final String? imagePath;

  Diary({
    required this.date,
    required this.mainEmotion,
    required this.subEmotion,
    required this.time,
    required this.place,
    required this.reason,
    required this.diaryContent,
    required this.imagePath,
  });

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