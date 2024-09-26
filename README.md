# <img src="https://github.com/user-attachments/assets/c7fc337c-f15a-4060-83be-8bbe8cb98ccd" width="30 " height="30"> MoodDiary


> **버튼으로 작성하는 간편한 일기 작성 앱**
      
---

## 📅 **제작 기간 & 참여 인원**
- **기간**: 2024년 1월 5일 ~ 3월 20일 
- **참여 인원**: 1인 프로젝트

## 📜 **기획 문서**
- [기획서 보기](https://docs.google.com/presentation/d/1PrNbnWb5IcI91bzLcCeA4jPPqkPzpPLcLqqSddak5GI/edit#slide=id.g3040118c9d1_0_435)

## 🛠 **사용 기술**

### Back-end
- `Firebase`

### Front-end
- `Flutter`

## 🎯 **프로젝트 목표**



1. **JSON 파일로 버튼 생성**: 사용자가 버튼을 클릭함으로써 동적으로 데이터를 표시할 수 있도록 JSON 파일을 활용.

2. **Provider를 통한 데이터 관리**: 상태 관리를 위해 Provider 패턴을 사용하여 앱 내 데이터 정보를 지속적으로 유지.

3. **Firebase 및 Firestore를 통한 로그인 기능 구현**: 사용자 인증을 위해 Firebase와 Firestore를 사용하여 간편한 로그인 기능을 개발.

4. **날씨 API 연동**: 외부 날씨 API를 활용하여 실시간 날씨 정보를 가져오고, 이를 기반으로 화면을 렌더링할 수 있도록 구현.

5. **Google AdMob을 이용한 배너 광고 추가**: 앱의 수익화를 위해 Google AdMob을 통합하여 배너 광고를 표시.

## 🗝 **핵심 기능**

1. **일기 작성 기능**: 
   - 메인 화면에 달력이 있으며, 현재 날짜가 선택되고, 이미 작성된 날짜는 점으로 표시. 
   - 이미 작성된 날짜를 누르면 해당 날짜에 작성했던 일기를 볼 수 있으며, 다시 작성하려고 할 경우 확인 메시지가 나타남.
2. **차트 페이지**: 
   - 일기를 쓰기 시작한 날짜, 마지막 작성 날짜, 총 작성 횟수가 표시되며, 2주간의 기분을 보여주는 파이차트가 있음.
3. **일기 리스트**: 
   - 작성한 일기를 목록으로 나열하고, 텍스트 검색 기능으로 특정 일기를 찾을 수 있음.
4. **알림 기능**: 
   - 알람 시간을 설정하면 푸쉬 알람으로 알림을 받을 수 있음.
5. **프로필 관리**: 
   - 로그인 시 작성하는 기본 프로필 정보를 확인하고 수정할 수 있으며, 이 정보는 Firestore에 저장됨.
6. **로그인 지원**: 
   - 구글 로그인과 카카오 로그인을 지원하며, 카카오 로그인은 Firebase에서 지원하지 않기 때문에 커스텀 토큰을 이용해 로그인 구현.


## 🚧 **핵심 트러블 슈팅**

 ### 1.버튼 로직 오류

**문제 상황**

처음에 JSON 파일을 사용하여 버튼을 만들었으나, 버튼이 제대로 생성되지 않았고 코드에서 여러 가지 오류가 발생. 특히 체크박스 선택 후 대화 리스트가 올바르게 업데이트되지 않았음.

**원인 분석**
1. **대화 리스트 업데이트 로직**: 대화 리스트를 업데이트하는 로직이 불완전하여, 체크박스 선택 시 올바른 대화 내용이 추가되지 않았음.
2. **상태 관리**: 체크박스의 상태 관리가 제대로 이루어지지 않아, 이미 선택된 옵션이 다시 선택되거나 올바르게 표시되지 않았음.

**해결 방법**

`CheckBoxModel`, `SentenceModel`, 그리고 `Conversation` 클래스를 사용하여 체크박스 선택 시 대화 리스트를 올바르게 업데이트하는 로직을 구현.

#### 1. CheckBoxModel 클래스
<details>
<summary>💻 코드</summary>
<div markdown="1">

 ```dart
class CheckBoxModel extends Conversation {
  bool isChecked;
  dynamic next;

  CheckBoxModel({
    required String id,
    required String content,
    required this.isChecked,
    required this.next
  }) : super(id: id, content: content);
}
isChecked: 체크박스의 선택 여부를 나타내며, 사용자가 선택 시 true로 설정.
next: 다음 대화나 옵션을 정의하는 동적 값.

 ```
</div>
</details>
2. Conversation 추상 클래스
<details>
<summary>💻 코드</summary>
<div markdown="1">

```dart


abstract class Conversation {
  final String id;
  final String content;

  Conversation({required this.id, required this.content});
}
대화 내용의 기본 구조를 정의하여, 코드의 일관성을 유지.

 ```
</div>
</details>
3. SentenceModel 클래스
<details>
<summary>💻 코드</summary>
<div markdown="1">

```dart

class SentenceModel extends Conversation {
  final bool isUser;

  SentenceModel({
    required String id,
    required String content,
    required this.isUser
  }) : super(id: id, content: content);
}
사용자가 작성한 문장이나 시스템의 응답을 나타내며, 대화의 흐름을 관리.
 ```
</div>
</details>

이러한 수정으로 인해 버튼 일기가 정상적으로 작동하게 되었으며, 사용자가 체크박스를 선택할 때마다 대화 리스트가 올바르게 업데이트되고, 다음 대화 및 옵션이 적절히 표시. JSON 파일의 구조와 체크박스 선택 로직을 이해하고 구현함으로써 문제를 해결할 수 있었다.

 ### 2. 이미지 저장 기능

**문제 상황**

처음에는 인자값을 사용하여 이미지를 전달하고 저장하려고 했으나, 선택된 이미지가 없다는 오류 메시지가 계속 발생. 이후 전역 변수를 사용하여 이미지를 선택하고 저장하려고 했으나, 또 다른 오류가 발생.

### 원인 분석
1. **인자값 사용**: 
   - `OptionButton` 위젯에서 버튼을 누르면 이미지 피커 패키지를 이용해 사진을 선택하고 선택된 사진은 `ChatBotScreen`에서 저장 버튼을 누를 때 내장 저장소에 저장.
    이미지 경로는 선택되었지만, `ChatBotScreen`으로 인자값을 전달할 때 이미지 경로가 제대로 전달되지 않아 오류가 발생.
    이로 인해 저장 과정에서 "선택된 이미지가 없습니다."라는 메시지가 출력되었음.

2. **전역 변수 사용**:
   - 전역 변수를 사용했으나, 상태 관리가 제대로 이루어지지 않아 UI와 데이터의 불일치가 발생.
  
### 해결 방법

`Provider` 패턴을 사용하여 이미지 경로를 관리.

#### 1. ImagePathProvider 클래스
- `ChangeNotifier`를 상속받아 이미지 경로를 관리합니다.
- 이미지 경로가 변경될 때마다 UI에 알림을 줘서 업데이트가 반영되도록 합니다.
<details>
<summary>💻 코드</summary>
<div markdown="1">

 ```dart
class ImagePathProvider with ChangeNotifier {
  String? _imagePath;

  String? get imagePath => _imagePath;

  set imagePath(String? path) {
    _imagePath = path;
    notifyListeners();
  }
}
2. 이미지 선택 및 저장 과정
ImageHandler 클래스에서 pickImage 메소드를 통해 사용자가 선택한 이미지를 ImagePathProvider에 저장.
dart


Future<void> pickImage(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    Provider.of<ImagePathProvider>(context, listen: false).imagePath = image.path;
  } else {
    Provider.of<ImagePathProvider>(context, listen: false).imagePath = null;
  }
}
일기 저장 시 선택된 이미지 경로를 ImagePathProvider에서 가져와 사용.
 ```
</div>
</details>
결과
Provider를 사용한 결과, 이미지 선택 후 경로가 제대로 저장되었고, UI도 정상적으로 업데이트되었음. 상태 관리가 개선되어 오류가 해결되었으며, 이미지 저장 기능이 원활하게 작동.

### 3. 알림 권한 요청 및 설정

**문제 상황**
- Play Store에서 앱이 실행될 때, 이전에는 자동으로 앱에대한 권한이 허용되었으나, 업데이트로 인해 사용자가 직접 권한을 허용하도록 변경되었음. 이로 인해 권한을 직접 설정하는 기능을 추가하라고 경고를 받음

**해결 방법**

- `PermissionHandler` 패키지를 사용하여 알림 권한을 요청하는 다이얼로그를 구현. 사용자가 권한을 허용하지 않은 경우, 설정 화면으로 이동하도록 하여 개선.

#### 1. PermissionRequestDialog 클래스
- 알림 권한 요청을 위한 다이얼로그를 구현.

<details>
<summary>💻 코드</summary>
<div markdown="1">

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestDialog extends StatefulWidget {
  const PermissionRequestDialog({Key? key}) : super(key: key);

  @override
  PermissionRequestDialogState createState() => PermissionRequestDialogState();
}

class PermissionRequestDialogState extends State<PermissionRequestDialog> {
  @override
  void initState() {
    super.initState();
    _requestPermissions(context);
  }

  void _requestPermissions(BuildContext context) async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        // 권한이 granted된 경우 추가 작업 수행
        Navigator.of(context).pop();
      } else {
        // 권한이 denied된 경우 사용자에게 알림
        // 이미 다이얼로그가 열려있으므로 추가 작업 불필요
      }
    } else {
      // 권한이 이미 granted된 경우 다이얼로그 닫기
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      title: const Text('알림 권한 요청'),
      content: const Text('알림 기능을 사용하기 위해서는 알림 권한이 필요합니다.'),
      actions: <Widget>[
        TextButton(
          child: const Text('설정'),
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
        ),
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
```
</div> </details>
결과

이 다이얼로그를 통해 사용자는 알림 권한을 쉽게 요청할 수 있으며, 권한이 거부된 경우 설정 화면으로 직접 이동하여 권한을 변경할 수 있음. 이를 통해 앱이 꺼졌을 때도 알림을 받을 수 있도록 개선. 또한, Play Store의 경고도 해결 하였음.

## 🔧 **그 외 트러블 슈팅**

### 1. **자동 스크롤 기능 구현**
- 대화 중 버튼을 선택할 때마다 새로운 선택지가 리스트에 추가되어 사용자가 수동으로 스크롤을 내려야 하는 문제를 해결하기 위해 자동 스크롤 기능을 구현.

<details>
<summary>💻 코드</summary>
<div markdown="1">

```dart
void scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  });
}
```
</div> </details>

### 2. 이메일 전송 기능 오류

- 앱에서 이메일을 보내기 위한 기능을 구현했으나, 버튼 클릭 시 오류가 발생하여 이메일 전송창으로 들어가지지 않음.
- AndroidManifest.xml 파일에 다음과 같은 `<queries>` 태그를 추가하여 이메일 전송 인텐트를 설정했습니다.


<details>
<summary>💻 코드</summary>
<div markdown="1">

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.SENDTO" />
        <data android:scheme="mailto" />
    </intent>
</queries>
```
</div> </details>


## **앱 실행 화면**
<img src="https://github.com/user-attachments/assets/80e41dd7-ae65-4fc9-825e-2cc07a739bd9"  width="200">
<img src="https://github.com/user-attachments/assets/3307ee5a-dc4c-418f-9c31-69c5e2a4fa2a"  width="200">
<img src="https://github.com/user-attachments/assets/e6294ae2-e5ed-4d92-981c-4276e7c53c33"  width="200">
<img src="https://github.com/user-attachments/assets/8cbbec03-d640-462d-9774-0345e8a6dadd"  width="200">
<img src="https://github.com/user-attachments/assets/d05dc23c-d8a6-47fc-a759-04b726d2f9fe"  width="200">
<img src="https://github.com/user-attachments/assets/550bd424-04f2-48c5-8024-708ddfe4eef8"  width="200">






## 📥 **다운로드 링크**


- [Google Play Store에서 다운로드](https://play.google.com/store/apps/details?id=com.junhajeonghoon.smooddiary)

