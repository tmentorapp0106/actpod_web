import 'package:flutter/material.dart';

class DesignShadow {
  static List<BoxShadow> shadow = [
    BoxShadow(
      offset: const Offset(0, 2),
      color: Color(0xFF200066).withOpacity(0.08),
      spreadRadius: 2,
      blurRadius: 12,
    ),
  ];
}