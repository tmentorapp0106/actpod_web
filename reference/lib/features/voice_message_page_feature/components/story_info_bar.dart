import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/components/centered_marquee.dart';
import 'package:quick_share_app/features/user_info_feature/screens/other_user_info_screen.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/story_image.dart';
import 'package:quick_share_app/utils/string_utils.dart';

import '../../../config/color.dart';
import '../providers.dart';

class StoryInfoBarWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    return storyInfo == null? const SizedBox.shrink() : Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoryImage(),
        SizedBox(width: 8.w,),
        SizedBox(
          height: 98.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              const Spacer(),
              SizedBox(
                width: 204.w,
                child: Text(
                  storyInfo.storyName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 204.w,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.w),
                          child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Image.network(
                                storyInfo.channelImageUrl,
                              )
                          )
                      )
                    ),
                    SizedBox(width: 4.w,),
                    Text(
                        StringUtils.shorten(storyInfo.channelName, 40),
                        style: TextStyle(
                          color: ConfigColor.textColorDefault,
                          fontSize: 12.w
                        )
                    ),
                  ],
                ),
              ),
              const Spacer()
            ]
          )
        ),
      ],
    );
  }
}