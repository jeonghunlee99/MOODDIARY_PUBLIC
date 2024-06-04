import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  static Future<bool> handleGoogleSignIn(Function onSuccess) async {
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        UserCredential authResult;
        User? oldUser;
        bool isLinked = false; // 'isLinked' 변수를 함수 범위에서 선언

        if (firebaseAuth.currentUser != null) {
          oldUser = firebaseAuth.currentUser;

          // 사용자가 이미 Google 로그인에 연결되어 있는지 확인
          isLinked = oldUser!.providerData.any((userInfo) => userInfo.providerId == 'google.com');

          if (!isLinked) {
            // 연결되어 있지 않은 경우, Google 로그인을 연결
            authResult = await oldUser.linkWithCredential(credential);
          } else {
            // 이미 연결되어 있는 경우, 기존에 연결된 Google 계정으로 로그인 계속
            authResult = await firebaseAuth.signInWithCredential(credential);
          }
        } else {
          authResult = await firebaseAuth.signInWithCredential(credential);
        }

        final User? newUser = authResult.user;
        if (newUser != null) {
          debugPrint("구글 로그인 성공: ${newUser.displayName ?? newUser.email ?? newUser.uid}");

          if (oldUser != null && !isLinked) {
            await _updateUserDataAfterGoogleSignIn(oldUser.uid, newUser.uid);
          }
          onSuccess();
          return true;
          // 로그인 성공
        }
      } catch (e) {
        debugPrint("구글 로그인 실패: $e");
      }
    } else {
      debugPrint("구글 로그인 취소");
    }
    return false;  // 로그인 실패
  }

  static Future<void> _updateUserDataAfterGoogleSignIn(String oldUid, String newUid) async {
    // Firestore에 접근
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 이전 UID에 해당하는 문서를 가져옴
    DocumentSnapshot oldDocument = await firestore.collection('users').doc(oldUid).get();

    if (oldDocument.exists) {
      Map<String, dynamic>? data = oldDocument.data() as Map<String, dynamic>?;
      if (data != null) {
        // 새 UID로 문서를 생성하고, 이전 문서의 데이터를 복사
        await firestore.collection('users').doc(newUid).set(data);
      } else {
        debugPrint("No data in old document");
      }
    } else {
      debugPrint("Old document does not exist");
    }
  }
}
