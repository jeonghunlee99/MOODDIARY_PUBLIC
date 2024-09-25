import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mooddiary/viewmodels/diary_list_viewmodel.dart';
import 'package:mooddiary/viewmodels/image_path_provider.dart';
import 'package:mooddiary/utils/color_table.dart';
import 'package:mooddiary/utils/constant.dart';
import 'package:mooddiary/viewmodels/mood_chart_view_model.dart';
import 'package:mooddiary/viewmodels/option_button_viewmodel.dart';
import 'package:mooddiary/widgets/option_button.dart';
import 'package:provider/provider.dart';
import 'package:mooddiary/screen/homepage.dart';
import 'api/weather_api.dart';
import 'models/checkbox_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/config/.env');
    KakaoSdk.init(nativeAppKey: nativeAppKey);
    await Firebase.initializeApp();
    MobileAds.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => WeatherService(apiKey: apiKey)),
        ChangeNotifierProvider(create: (context) => ImagePathProvider()),
        ChangeNotifierProvider(create: (context) => DiaryListViewModel()),
        ChangeNotifierProvider(create: (context) => ChartViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? weatherCondition;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  fetchWeather() async {
    WeatherService weatherService =
        Provider.of<WeatherService>(context, listen: false);
    weatherCondition = await weatherService.getLocationAndWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'myfont',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          onSecondary: onSecondaryColor,
          secondary: secondaryColor,
        ),
        brightness: Brightness.light,
      ),
      home: FutureBuilder(
        future: fetchWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: double.infinity, // 화면 너비의 최대 크기로 설정
              height: double.infinity, // 화면 높이의 최대 크기로 설정
              color: Colors.white, // 배경색을 흰색으로 설정합니다.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // 로딩 인디케이터를 표시합니다.
                  SizedBox(height: 20), // 간격을 조절합니다.
                  Text(
                    '날씨 정보를 얻는 중입니다! 😄',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[400],
                      decoration: TextDecoration.none, // 밑줄 제거
                    ),
                  ),
                ],
              ),
            );
          } else {
            return HomePage(); // 데이터가 준비되면 HomePage를 빌드합니다.
          }
        },
      ),
    );
  }
}
