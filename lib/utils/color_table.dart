import 'package:flutter/material.dart';

const seedColor = Color(0x00a1887f);
const secondaryColor = Color(0xFFD2B48C);
const onSecondaryColor = Color(0xFFFAEBD7);

LinearGradient getGradientColor(String? mainEmotion) {
  switch (mainEmotion) {
    case '기쁨':
      return const LinearGradient(
        colors: [Color(0xFFFFA000), Color(0xFFFF6D00), Color(0xFFFF3D00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case '행복':
      return const LinearGradient(
        colors: [Color(0xFFFFEB3B), Color(0xFFFFC107), Color(0xFFFFA000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case '슬픔':
      return const LinearGradient(
        colors: [Color(0xFF757575), Color(0xFF424242)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case '우울':
      return const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    default:
      return const LinearGradient(
        colors: [Colors.grey, Colors.grey],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
  }
}

