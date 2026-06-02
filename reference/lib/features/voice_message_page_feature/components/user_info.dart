import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';

import '../../../config/color.dart';
import '../../user_info_feature/screens/other_user_info_screen.dart';
import '../providers.dart';

class UserInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar(storyInfo!.userId, storyInfo.avatarUrl, 16.w),
        SizedBox(width: 3.w,),
        Text(
          storyInfo.nickname,
          style: TextStyle(
            color: ConfigColor.textColorDefault,
            fontSize: 10.sp
          ),
        )
      ]
    );
  }
}