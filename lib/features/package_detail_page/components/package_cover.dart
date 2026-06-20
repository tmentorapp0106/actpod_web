import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:flutter/material.dart';

class PackageCover extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double badgeSize;

  const PackageCover({
    super.key,
    required this.imageUrl,
    required this.height,
    this.badgeSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFF1CF),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: packageAccent,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 14,
            child: PackageBadge(fontSize: badgeSize),
          ),
        ],
      ),
    );
  }
}

class PackageBadge extends StatelessWidget {
  final double fontSize;

  const PackageBadge({
    super.key,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.65,
        vertical: fontSize * 0.38,
      ),
      decoration: BoxDecoration(
        color: packageAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "套裝",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
