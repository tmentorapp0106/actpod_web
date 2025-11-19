import 'package:flutter/material.dart';

class PodCoin extends StatelessWidget {
  final double size;

  PodCoin({
    super.key,
    required this.size
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/podcoins.png",
      width: size,
      height: size,
      fit: BoxFit.fitWidth,
    );
  }
}