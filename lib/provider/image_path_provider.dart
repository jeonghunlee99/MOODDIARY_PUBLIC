import 'package:flutter/material.dart';

class ImagePathProvider with ChangeNotifier {
  String? _imagePath;

  String? get imagePath => _imagePath;

  set imagePath(String? path) {
    _imagePath = path;
    notifyListeners();
  }
}
