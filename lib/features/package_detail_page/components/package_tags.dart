import 'package:actpod_web/dto/package_dto.dart';
import 'package:flutter/material.dart';

class PackageTag extends StatelessWidget {
  final String text;

  const PackageTag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F4F4F),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PackageTags extends StatelessWidget {
  final PackageInfoItem package;

  const PackageTags({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => PackageTag(text: tag)).toList(),
    );
  }
}
