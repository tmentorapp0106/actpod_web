import 'package:actpod_web/features/player_page/components/user_info.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';

import '../../../components/centered_marquee.dart';
import '../../../components/channel_image.dart';

class StoryInfoBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            CenteredMarquee(
              maxWidth: 310.w,
              text: storyInfo == null? "" : storyInfo.storyName,
              color: Colors.black,
              fontSize: 24.w
            ),
            SizedBox(height: 8.h,),
            UserInfo(),
            Marquee(
              animationDuration: const Duration(seconds: 10),
              directionMarguee: DirectionMarguee.oneDirection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  storyInfo == null? const SizedBox.shrink() : ChannelImage(storyInfo.channelImageUrl, storyInfo.channelName, 20.w, 12.w),
                  SizedBox(width: 5.w,),
                  Text(
                    storyInfo == null? "" : storyInfo.channelName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.w
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