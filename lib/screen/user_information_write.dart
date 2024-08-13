import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:gsform/gs_form/widget/section.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:mooddiary/screen/homepage.dart';
import '../widgets/gs_button.dart';
import '../widgets/gs_date_picker.dart';

class MultiSectionForm extends StatefulWidget {
  const MultiSectionForm({super.key});

  @override
  MultiSectionFormState createState() => MultiSectionFormState();
}

class MultiSectionFormState extends State<MultiSectionForm> {
  GSForm? form;
  String? selectedGender;
  DateTime? selectedBirthdate;
  late User? user;
  late StreamSubscription<User?> _authSubscription;
  bool canPop = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    user = FirebaseAuth.instance.currentUser;
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
          setState(() {
            user = currentUser;
          });
        });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Auth 상태 변경 감지 중지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    form ??= GSForm.multiSection(context, sections: [
      GSSection(
        sectionTitle: '회원정보',
        fields: [
          GSField.text(
            tag: '이름',
            title: '이름',
            minLine: 1,
            maxLine: 1,
            required: true,
          ),
          GSButton(
            tag: '성별',
            title: '성별',
            items: const ['남자', '여자'],
            value: selectedGender,
            onChanged: (String? value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
          GSDatePicker(
            tag: '생년월일',
            title: '생년월일',
            selectedDate: selectedBirthdate,
            onDateChanged: (DateTime date) {
              setState(() {
                selectedBirthdate = date;
              });
            },
          ),
          GSField.text(
            tag: '이메일',
            title: '이메일',
            minLine: 1,
            maxLine: 1,
            required: true,
          ),
        ],
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('회원정보입력'),
      ),
      body: WillPopScope(
        onWillPop: () async => canPop,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12, top: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: form,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool isValid = form!.isValid();
                          if (isValid) {
                            Map<String, dynamic> formData = form!.onSubmit();
                            debugPrint(isValid.toString());
                            debugPrint(formData.toString());

                            try {
                              if (user != null) {
                                String uid = user!.uid;

                                Map<String, dynamic>? oldData =
                                await _loadUserDataFromFirestore(uid);
                                bool isGoogleSignedIn =
                                await _checkGoogleLoginStatus();
                                bool isKakaoSignedIn =
                                await _checkKakaoLoginStatus();

                                Map<String, dynamic> selectedData = {
                                  'name': formData['이름'],
                                  'sex': selectedGender,
                                  'birth':
                                  Timestamp.fromDate(selectedBirthdate!),
                                  'email': formData['이메일'],
                                  'uid': uid,
                                  'platform': isGoogleSignedIn
                                      ? 'google'
                                      : isKakaoSignedIn
                                      ? 'kakao'
                                      : 'none',
                                  ...?oldData,
                                };

                                await FirebaseFirestore.instance
                                    .collection('realusers')
                                    .doc(uid)
                                    .set(selectedData, SetOptions(merge: true));
                                debugPrint(
                                    'Data saved to Firestore successfully');

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .delete();
                                debugPrint(
                                    'Data deleted from Firestore successfully');

                                setState(() {
                                  canPop = true;
                                });

                                Navigator.pop(context);
                              } else {
                                debugPrint('User is not authenticated.');
                              }
                            } catch (e) {
                              debugPrint('Error saving data to Firestore: $e');
                            }
                          } else {
                            debugPrint(
                                'Form is not valid. Not saving data to Firestore.');
                          }
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                                  (route) => false
                          );
                        },
                        child: const Text('저장'),

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> _loadUserDataFromFirestore(String? uid) async {
  if (uid != null) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String collectionPath = 'users';
    String documentPath = uid;

    DocumentSnapshot snapshot =
    await firestore.collection(collectionPath).doc(documentPath).get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<bool> _checkGoogleLoginStatus() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isSignedIn = await googleSignIn.isSignedIn();
  return isSignedIn;
}

Future<bool> _checkKakaoLoginStatus() async {
  try {
    await kakao.UserApi.instance.accessTokenInfo();
    return true;
  } catch (e) {
    return false;
  }
}
