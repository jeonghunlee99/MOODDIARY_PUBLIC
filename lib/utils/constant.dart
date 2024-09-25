import 'package:flutter_dotenv/flutter_dotenv.dart';

final String nativeAppKey = dotenv.env['NATIVE_APP_KEY'] ?? '';
final String apiKey = dotenv.env['API_KEY'] ?? '';
final String adUnitId = dotenv.env['AD_UNIT_ID'] ?? '';
final String rewardAdId = dotenv.env['REWARD_AD_ID'] ?? '';
