import 'package:flutter/material.dart';

class DesignSystem {
  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0xFF200066).withOpacity(0.08),
      spreadRadius: 0,
      blurRadius: 6,
    ),
  ];

  static Color primary = const Color(0xFFFFBC1F);
  static Color primary500 = const Color(0xFFFFBC1F);
  static Color textColorGrey = const Color(0xFF8f8f8f);
  static Color borderGrey = const Color(0xFFe4e4e4);
  static Color backgroundGrey = const Color(0xFF4a4a4a);
}