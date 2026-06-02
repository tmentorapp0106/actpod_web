import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaveformPainter extends CustomPainter {
  final List<double> data;    // List of double values to be drawn
  final double barWidth;      // Width of each bar
  final double totalWidth;    // Total width of the canvas
  final Color color;          // Color of the bars
  final double stretch;
  final double height;
  final double scale;

  WaveformPainter({
    required this.data,
    this.barWidth = 1.5,
    required this.totalWidth,
    this.color = Colors.black,
    this.stretch = 0,
    this.height = 100,
    this.scale = 1
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // Determine how many bars you will draw
    int numberOfBars = (data.length).ceil(); // Count of even-indexed bars

    // Calculate the available spacing between bars
    double availableWidth = totalWidth - (numberOfBars * barWidth);
    double spacing = availableWidth / (numberOfBars - 1);

    // Calculate the total height of the canvas
    double canvasHeight = size.height;

    for (int i = 0; i < data.length; i++) {  // Increment by 2 to skip odd indices
      double xOffset = i * (barWidth + spacing);  // Adjust position with calculated spacing
      double barHeight = data[i] * height * scale + stretch;
      if(barHeight > height) {
        barHeight = height;
      }
      double yOffset = (canvasHeight - barHeight) / 2;  // Center the bars vertically

      // Draw each bar as a rectangle
      canvas.drawRRect(
        RRect.fromLTRBR(
          xOffset,
          yOffset,
          xOffset + barWidth, // Right
          yOffset + barHeight, // Bottom
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}