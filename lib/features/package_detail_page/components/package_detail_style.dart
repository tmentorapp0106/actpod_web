import 'package:flutter/material.dart';

const packageAccent = Color(0xFFFFA300);
const packageSoft = Color(0xFFFFFAEF);
const packageBorder = Color(0xFFFFD78A);

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
