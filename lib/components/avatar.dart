import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? userId;
  final String? avatarUrl;
  final double size;

  Avatar(this.userId, this.avatarUrl, this.size);

  @override
  Widget build(BuildContext context) {
    return avatarUrl == null || avatarUrl == ""? ClipOval(
      child: Image.asset(
        "assets/images/nullAvatar.png",
        width: size,
        height: size,
        fit: BoxFit.fitWidth,
      )
    ) : ClipOval(
      child: Image.network(
        avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.fitWidth,
      )
    );
  }
}