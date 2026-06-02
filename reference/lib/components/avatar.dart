import 'package:flutter/material.dart';

import '../features/user_info_feature/screens/other_user_info_screen.dart';
import '../router.dart';

class Avatar extends StatelessWidget {
  final String? userId;
  final String? avatarUrl;
  final Function? tapFunction;
  final double size;
  String? navigatorType = "shell";

  Avatar(this.userId, this.avatarUrl, this.size, {this.navigatorType, this.tapFunction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(userId == null) {
          if(tapFunction != null) {
            tapFunction!();
          }
          return;
        }
        router.push("/otherUserInfo/$userId");
      },
      child: avatarUrl == null || avatarUrl == ""? ClipOval(
        child: Image.asset(
          "assets/images/avatar.png",
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
      )
    );
  }
}