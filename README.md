# <img src="https://github.com/user-attachments/assets/0ea40838-544e-4b9d-adae-758f55cfdb59" width="30 " height="30"> foodrecipe



> **버튼으로 작성하는 간편한 일기 작성 앱**
      
---

## 📅 **제작 기간 & 참여 인원**
- **기간**: 2024년 3월 18일 ~ 4월 19일 
- **참여 인원**: 1인 프로젝트

## 📜 **기획 문서**
- [기획서 보기](https://docs.google.com/presentation/d/1PrNbnWb5IcI91bzLcCeA4jPPqkPzpPLcLqqSddak5GI/edit#slide=id.g3040118c9d1_0_435)

## 🛠 **사용 기술**

### Back-end
- `Firebase`

### Front-end
- `Flutter`

## 🎯 **프로젝트 목표**

1. **GitHub** 사용하여 `Check out`, `Merge`를 통한 협업
2. 대량 데이터를 `JSON` 파일화하여 코드 단순화
3. **MVVM 아키텍처** 준수하여 코드 구조 이해 및 적용
4. 상태관리를 위해 `Provider` 사용 숙달

## 🗝 **핵심 기능**

1. **다양한 카테고리별** 요리 레시피 제공
2. **즐겨찾기 기능** 및 재료 **장바구니 기능**

## 🚧 **핵심 트러블 슈팅**

1. **화면 깜빡임 문제**  
   - 로그인 시 즐겨찾기, 장바구니 목록 불러오기 후 페이지 이동 시 화면이 깜빡이는 문제를 `FutureBuilder`와 `Provider`를 사용해 해결

2. **즐겨찾기 목록 실시간 랜더링 문제**  
   - 즐겨찾기 추가 및 삭제 시 화면에 즉시 반영되지 않는 문제를 `Provider`로 해결

3. **즐겨찾기 정렬 문제**  
   - 즐겨찾기 시 음식이 카테고리별로 추가되는 문제를, 추가된 시간을 추적해 시간 기준으로 정렬하는 방식으로 해결

4. **Merge 충돌 문제**  
   - 팀 프로젝트에서 브랜치 병합 시 발생한 충돌 문제를 해결하기 위해 `Git`의 브랜치 및 병합 원리를 정확히 이해하고, 순서대로 `Push` 및 `Merge`하여 문제 해결

5. **MVVM 패턴 적용**  
   - 프로젝트 초기에는 코드가 명확한 구조 없이 혼재되어 있었으나, **MVVM 패턴** 도입 후 코드 구조화 및 유지보수가 용이해짐. `ViewModel`을 통한 데이터 바인딩으로 UI와 데이터 로직이 자연스럽게 분리됨.

## 🔧 **그 외 트러블 슈팅**

1. **AppBar 애니메이션 문제 해결**  
   - `SliverAppBar`를 사용하여 애니메이션 효과 문제 해결

2. **화면 랜더링 문제 해결**  
   - Mediaquery를 이용하여 각 휴대폰 기기들의 이미지크기를 조정함

3. **검색 기능 데이터 중복 문제 해결**
   - 이 문제를 해결하기 위해 Set<String> 자료구조를 사용하여 중복된 항목을 필터링 Set은 중복을 허용하지 않기 때문에, 검색 결과에서 중복된 음식 이름을 제거함
<details>
<summary>💻 코드</summary>
<div markdown="1">

 ```dart
  Widget _buildSuggestionsOrResults() {
      Set<String> uniqueNames = {};

      final List<Map<String, dynamic>> suggestionList = query.isEmpty
          ? []
          : _foodData.where((food) {
              if (food['name'].toLowerCase().contains(query.toLowerCase())) {
                return uniqueNames.add(food['name']);
              } else {
                return false;
              }
            }).toList();
  }

```

</div>
</details>

4.  **카카오 로그인 API를 사용해 사용자의 이름(닉네임)을 가져오려고 했으나, 예상대로 이름이 불러와지지 않는 문제가 발생**
- 이 문제를 해결하기 위해, 카카오 SDK에서 제공하는 UserApi.instance.me() 메서드를 사용해 사용자의 프로필 정보를 직접 불러오고, 이를 통해 사용자 닉네임을 얻는 코드를 작성함

    - UserApi.instance.me() 메서드를 통해 사용자 정보를 가져옴
    - 반환된 User 객체에서 카카오 계정(kakaoAccount)의 프로필(profile) 정보를 확인하고, 닉네임(nickname)을 가져옴
    - 오류가 발생할 경우 null을 반환하도록 예외 처리를 추가.
<details>
<summary>💻 코드</summary>
<div markdown="1">

 ```dart
Future<String?> getUserName() async {
    try {
      // 사용자 닉네임 가져오기
      User user = await UserApi.instance.me();
      return user.kakaoAccount?.profile?.nickname;
    } catch (error) {

      return null;
    }
  }
```
</div>
</details>

## **앱 실행 화면**
<img src="https://github.com/user-attachments/assets/19d44a85-363f-46fe-a205-f01562994ed44"  width="200">
<img src="https://github.com/user-attachments/assets/19d38e09-6a0a-4c5e-bca5-52e7259ab804"  width="200">
<img src="https://github.com/user-attachments/assets/983a5e65-c452-44e4-bd07-bb64c4e65860"  width="200">
<img src="https://github.com/user-attachments/assets/1b5d9a10-4604-419a-9d21-d4f0f968598e"  width="200">
<img src="https://github.com/user-attachments/assets/d78925b3-c1f2-45c5-b020-e34ddb0d0c63"  width="200">
<img src="https://github.com/user-attachments/assets/7db5a3d1-7421-4493-8e5f-9abdcd78809a"  width="200">


## 📥 **다운로드 링크**

- [Google Play Store에서 다운로드](https://play.google.com/store/apps/details?id=com.junhajeonghoon.foodrecipe)
