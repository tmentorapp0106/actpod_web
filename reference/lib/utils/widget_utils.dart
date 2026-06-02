import 'package:flutter/material.dart';

class WidgetUtils {

  static Size getTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static Size getTextSizeWithMaxLine(String text, TextStyle style, int maxLine) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: maxLine, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static bool hasTextOverflow(
      String text,
      TextStyle style,
      {double minWidth = 0,
        double maxWidth = double.infinity,
        int maxLines = 2
      }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

}