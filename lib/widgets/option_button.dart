import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../provider/image_path_provider.dart';
import '../models/checkbox_model.dart';
import '../models/conversation.dart';
import '../viewmodels/chatlogic.dart';
import '../screen/homepage.dart';
import 'package:google_sign_in/google_sign_in.dart';


class OptionButton extends StatefulWidget {
  final CheckBoxModel checkBoxModel;
  final List<String> selectedOptions;
  final List<Conversation> conversations;
  final Function onPressedCallback;
  final DateTime selectedDate;

  const OptionButton({
    Key? key,
    required this.checkBoxModel,
    required this.selectedOptions,
    required this.conversations,
    required this.onPressedCallback,
    required this.selectedDate,
  }) : super(key: key);

  @override
  OptionButtonState createState() => OptionButtonState();
}

class OptionButtonState extends State<OptionButton> {
  double _opacity = 0;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      setState(() {
        _opacity = 1;
      });
    });
  }

  Future<bool> checkGoogleLoginStatus() async {
    try {
      bool isSignedIn = await googleSignIn.isSignedIn();
      return isSignedIn;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkKakaoLoginStatus() async {
    try {
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  String? _selectedImagePath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImagePath = image.path;
      debugPrint('$_selectedImagePath');
      Provider
          .of<ImagePathProvider>(context, listen: false)
          .imagePath =
      _selectedImagePath!;
    } else {

      _selectedImagePath = null;
      Provider.of<ImagePathProvider>(context, listen: false)
          .imagePath = null;
    }
  }

  Future<void> _saveImage(String imagePath, DateTime selectedDate) async {
    final File imageFile = File(imagePath);
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;


    final String fileName =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(
        2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    final File newImageFile = await imageFile.copy('$path/$fileName.png');

    _selectedImagePath = newImageFile.path;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1000),
      child: SizedBox(
        width: screenWidth * 0.35,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(Colors.grey[100]!),
            elevation: MaterialStateProperty.all(0),
            foregroundColor: MaterialStateProperty.all<Color?>(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          onPressed: () async {
            if (widget.checkBoxModel.content == "네" ||
                widget.checkBoxModel.content == "직접 작성") {
              TextEditingController diaryController = TextEditingController();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    title: const Text(
                      "일기 작성",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    content: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: diaryController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "여기에 일기를 작성하세요",
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          "저장",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () async {

                          String? imagePath = Provider.of<ImagePathProvider>(context, listen: false).imagePath;

                          if (imagePath != null) {

                            await _saveImage(imagePath, widget.selectedDate);
                          } else {
                            debugPrint("선택된 이미지가 없습니다.");
                          }
                          DateTime selectedDate = widget.selectedDate;
                          String currentYear = selectedDate.year.toString();
                          String currentDate =
                              '${selectedDate.month.toString().padLeft(
                              2, '0')}-${selectedDate.day.toString().padLeft(
                              2, '0')}';

                          Directory docDir =
                          await getApplicationDocumentsDirectory();
                          String filePath = '${docDir.path}/$currentYear.json';
                          File diaryFile = File(filePath);

                          var diaryData = [
                            {
                              'date': currentDate,
                              'mainEmotion': widget.selectedOptions[0],
                              'subEmotion': widget.selectedOptions[1],
                              'time': widget.selectedOptions[2],
                              'place': widget.selectedOptions[3],
                              'reason': widget.selectedOptions[4],
                              'diaryContent': diaryController.text,
                              'imagePath': Provider
                                  .of<ImagePathProvider>(
                                  context,
                                  listen: false)
                                  .imagePath,
                            }
                          ];
                          List<Map<String, dynamic>> allDiaries = [];
                          if (await diaryFile.exists()) {
                            String existingContent =
                            await diaryFile.readAsString();
                            allDiaries = List<Map<String, dynamic>>.from(
                                jsonDecode(existingContent));

                            int existingDiaryIndex = allDiaries.indexWhere(
                                    (diary) => diary['date'] == currentDate);
                            if (existingDiaryIndex != -1) {
                              allDiaries[existingDiaryIndex] = diaryData[0];
                            } else {
                              allDiaries.addAll(diaryData);
                            }
                          } else {
                            allDiaries.addAll(diaryData);
                          }
                          allDiaries.sort((a, b) {
                            DateTime dateA =
                            DateTime.parse("$currentYear-${a['date']}");
                            DateTime dateB =
                            DateTime.parse("$currentYear-${b['date']}");
                            return dateA.compareTo(dateB);
                          });

                          JsonEncoder encoder = const JsonEncoder.withIndent('    ');
                          String diaryJson = encoder.convert(allDiaries);
                          await diaryFile.writeAsString(diaryJson);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return const Material(
                                type: MaterialType.transparency,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.0),
                                        child: Text('일기를 저장중이에요!',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          Future.delayed(const Duration(seconds: 3), () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                                  (route) => false,
                            );
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
            if (widget.checkBoxModel.content == "아니요") {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/book.png.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      height: 300,
                      width: 300,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "선택한 버튼",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(10.0),

                              children: [
                                Container(
                                  alignment: Alignment.center,

                                  child: Text(
                                    "주요 감정: ${widget.selectedOptions[0]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "세부 감정: ${widget.selectedOptions[1]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "시간대: ${widget.selectedOptions[2]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "장소: ${widget.selectedOptions[3]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "이유: ${widget.selectedOptions[4]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            child: const Text(
                              "저장",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                            onPressed: () async {
                              String? imagePath =
                                  Provider
                                      .of<ImagePathProvider>(context,
                                      listen: false)
                                      .imagePath;

                              if (imagePath != null) {

                                await _saveImage(
                                    imagePath, widget.selectedDate);
                              } else {
                                debugPrint("선택된 이미지가 없습니다.");
                              }
                              DateTime selectedDate = widget.selectedDate;
                              String currentYear = selectedDate.year.toString();
                              String currentDate =
                                  '${selectedDate.month.toString().padLeft(
                                  2, '0')}-${selectedDate.day.toString()
                                  .padLeft(2, '0')}';

                              Directory docDir =
                              await getApplicationDocumentsDirectory();
                              String filePath =
                                  '${docDir.path}/$currentYear.json';
                              File diaryFile = File(filePath);
                              var diaryData = [
                                {
                                  'date': currentDate,
                                  'mainEmotion': widget.selectedOptions[0],
                                  'subEmotion': widget.selectedOptions[1],
                                  'time': widget.selectedOptions[2],
                                  'place': widget.selectedOptions[3],
                                  'reason': widget.selectedOptions[4],
                                  'imagePath': Provider
                                      .of<ImagePathProvider>(
                                      context,
                                      listen: false)
                                      .imagePath,
                                }
                              ];
                              List<Map<String, dynamic>> allDiaries = [];
                              if (await diaryFile.exists()) {
                                String existingContent =
                                await diaryFile.readAsString();
                                allDiaries = List<Map<String, dynamic>>.from(
                                    jsonDecode(existingContent));

                                int existingDiaryIndex = allDiaries.indexWhere(
                                        (diary) =>
                                    diary['date'] == currentDate);
                                if (existingDiaryIndex != -1) {
                                  allDiaries[existingDiaryIndex] = diaryData[0];
                                } else {
                                  allDiaries.addAll(diaryData);
                                }
                              } else {
                                allDiaries.addAll(diaryData);
                              }
                              allDiaries.sort((a, b) {
                                DateTime dateA =
                                DateTime.parse("$currentYear-${a['date']}");
                                DateTime dateB =
                                DateTime.parse("$currentYear-${b['date']}");
                                return dateA.compareTo(dateB);
                              });

                              JsonEncoder encoder =
                              const JsonEncoder.withIndent('    ');
                              String diaryJson = encoder.convert(allDiaries);
                              await diaryFile.writeAsString(diaryJson);

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return const Material(
                                    type: MaterialType.transparency,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 20.0),
                                            child: Text('일기를 저장중이에요!',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              Future.delayed(const Duration(seconds: 3), () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                      (route) => false,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (widget.checkBoxModel.content == "첨부하기") {
              await _pickImage();
            } else if (widget.checkBoxModel.content == "계속 작성") {

              Provider
                  .of<ImagePathProvider>(context, listen: false)
                  .imagePath =
              null;
            }
            setState(() {
              ChatLogic.handleCheckBoxSelection(widget.checkBoxModel,
                  widget.conversations, widget.selectedOptions);
              widget.onPressedCallback();
            });
          },
          child: Text(widget.checkBoxModel.content),
        ),
      ),
    );
  }
}
