import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mooddiary/provider/image_path_provider.dart';
import 'package:mooddiary/utils/color_table.dart';
import 'package:mooddiary/utils/constant.dart';
import 'package:provider/provider.dart';
import 'package:mooddiary/screen/homepage.dart';
import 'api/weather_api.dart';


void main() async {
  KakaoSdk.init(nativeAppKey:nativeAppKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherService(apiKey: apiKey)),
        ChangeNotifierProvider(create: (context) => ImagePathProvider()),
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
    WeatherService weatherService = Provider.of<WeatherService>(context, listen: false);
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
            return Center(child: CircularProgressIndicator());  // 데이터를 기다리는 동안 로딩 인디케이터를 표시합니다.
          } else {
            return HomePage();  // 데이터가 준비되면 HomePage를 빌드합니다.
          }
        },
      ),
    );
  }
}