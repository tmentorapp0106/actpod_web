import 'package:flutter/material.dart';

class FireworkCommentStateDto {
  Map<String, bool> showMap;
  List<Widget> commentWidgets;

  FireworkCommentStateDto({
    required this.showMap,
    required this.commentWidgets
  });
}