import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';

import '../config/color.dart';

class CenteredMarquee extends StatelessWidget {
  final double maxWidth;
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;

  CenteredMarquee({
    super.key,
    this.maxWidth = 300,
    this.text = "",
    this.color = Colors.black,
    this.fontSize = 30,
    this.fontWeight
  });

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    int duration = (textWidth * 20).toInt();

    return SizedBox(
      width: maxWidth,
      child: textWidth < maxWidth? Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      )
      : Marquee(
        animationDuration: Duration(milliseconds: duration),
        directionMarguee: DirectionMarguee.oneDirection,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}