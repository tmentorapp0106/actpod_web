import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/voice_message_page_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

class VoiceMessageListTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        ref.watch(storyInfoProvider)?.userId == UserService.getUserInfo()?.userId || ref.watch(storyInfoProvider)?.collaboratorId == UserService.getUserInfo()?.userId? "聽眾留言" : "你的留言",
        style: TextStyle(
          fontSize: 22.w,
          fontWeight: FontWeight.bold
        ),
      )
    );
  }
}