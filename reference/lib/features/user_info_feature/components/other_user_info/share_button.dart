import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../dto/user_info_dto.dart';
import '../../providers.dart';

class PersonalInfoShareButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(otherUserInfoProvider);
    return Visibility(
      visible: userInfo != null,
      child: InkWell(
        borderRadius: BorderRadius.circular(25.w),
        onTap: () async {
          final box = context.findRenderObject() as RenderBox?;
          SharePlus.instance.share(
              ShareParams(
                text: 'https://web.actpodapp.com/personal/${userInfo!.userId}?openExternalBrowser=1',
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
              )
          );
        },
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              Icons.share_rounded,
              size: 24.w,
              color: Colors.black
            )
        ),
      )
    );
  }
}