import 'package:actpod_web/components/channel_image.dart';
import 'package:actpod_web/features/player_page/components/web/web_user_info.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';

import '../../../../components/centered_marquee.dart';

class WebStoryInfoBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            CenteredMarquee(
              maxWidth: 120.w,
              text: storyInfo == null? "" : storyInfo.storyName,
              color: Colors.black,
              fontSize: 6.w
            ),
            SizedBox(height: 4.h,),
            WebUserInfo(),
            SizedBox(height: 4.h,),
            Marquee(
              animationDuration: const Duration(seconds: 10),
              directionMarguee: DirectionMarguee.oneDirection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  storyInfo == null? const SizedBox.shrink() : ChannelImage(storyInfo.channelImageUrl, storyInfo.channelName, 6.w, 3.w),
                  SizedBox(width: 2.w,),
                  Text(
                    storyInfo == null? "" : storyInfo.channelName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 4.w
                    )
                  )
                ]
              )
            ),
          ]
        ),
      ],
    );
  }
}