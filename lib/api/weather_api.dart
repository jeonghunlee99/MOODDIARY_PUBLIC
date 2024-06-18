import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService with ChangeNotifier {
  final String apiKey;
  double? latitude;
  double? longitude;

  WeatherService({required this.apiKey});

  String _weatherCondition = '';
  String get weatherCondition => _weatherCondition;

  Future<String> getLocationAndWeather() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('위치 권한이 거부되었습니다.');
        return '위치 권한이 거부되었습니다.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      latitude = position.latitude.toDouble();
      longitude = position.longitude.toDouble();

      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherData = jsonDecode(response.body);
        _weatherCondition = weatherData['weather'][0]['main'];

        notifyListeners();
        debugPrint("$_weatherCondition");
        print("안녕하세요 여기에요");
        return weatherCondition;

      } else {
        debugPrint('날씨 정보를 가져오는데 실패했습니다.');
        return '날씨 정보를 가져오는데 실패했습니다.';
      }
    } catch (e) {
      debugPrint('위치 정보를 가져오는데 실패했습니다: $e');
      return '위치 정보를 가져오는데 실패했습니다: $e';
    }

  }
}
