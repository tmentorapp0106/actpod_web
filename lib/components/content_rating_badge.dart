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
    final foregroundColor = Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "18+",
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11.w,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}