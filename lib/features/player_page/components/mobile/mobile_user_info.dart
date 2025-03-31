import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/avatar.dart';

class MobileUserInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        storyInfo == null? const SizedBox.shrink() : Avatar(storyInfo.userId, storyInfo.avatarUrl, 20.w),
        SizedBox(width: 3.w,),
        Text(
          storyInfo == null? "" : storyInfo.nickname,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.w
          ),
        )
      ]
    );
  }
}