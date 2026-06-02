import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';

import '../../../dto/channel_dto.dart';
import '../provider.dart';

class UserInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChannelDto? channelInfo = ref.watch(channelInfoProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        channelInfo == null? Avatar("", "", 20.w) : Avatar(channelInfo.userId, channelInfo.userAvatarUrl, 20.w),
        SizedBox(width: 4.w,),
        Text(
          channelInfo == null? "" : channelInfo.nickname,
          style: TextStyle(
            fontSize: 12.w,
            fontWeight: FontWeight.bold
          ),
        )
      ],
    );
  }
}