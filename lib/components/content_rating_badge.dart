import 'package:actpod_web/design_system/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentRatingBadge extends StatelessWidget {
  final String contentRating;
  final bool compact;
  final bool overlay;

  const ContentRatingBadge({
    super.key,
    required this.contentRating,
    this.compact = false,
    this.overlay = false,
  });

  bool get isAdult => contentRating.toLowerCase() == "adult";

  @override
  Widget build(BuildContext context) {
    if (!isAdult) {
      return const SizedBox.shrink();
    }

    final backgroundColor =
        overlay ? Colors.black.withValues(alpha: 0.72) : DesignColor.attention;
    const foregroundColor = Colors.white;
    final horizontalPadding =
        (compact ? 6.w : 8.w).clamp(compact ? 6.0 : 8.0, compact ? 8.0 : 10.0);
    final verticalPadding =
        (compact ? 2.h : 4.h).clamp(compact ? 2.0 : 4.0, compact ? 3.0 : 5.0);
    final borderRadius = 12.w.clamp(12.0, 14.0);
    final fontSize = 11.w.clamp(11.0, compact ? 12.0 : 13.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "18+",
            style: TextStyle(
              color: foregroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
