import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../../dto/user_info_dto.dart';
import '../../providers/providers.dart';

class RecordTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserInfoDto? userInfo = UserService.getUserInfo();
    String text = userInfo == null? "上傳故事，成為 Podcaster" : "Hey, ${userInfo.nickname} 上傳故事，成為 Podcaster";

    return Visibility(
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      visible: ref.watch(recordStatusProvider) == "pending",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 260.w,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.w,
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            )
          ),
        ],
      )
    );
  }
}