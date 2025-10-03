import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';

import '../../../../components/centered_marquee.dart';
import '../../../../components/channel_image.dart';

class MobileStoryInfoBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded( // <-- makes the column take the available width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title line
              Align(
                alignment: Alignment.center, // centers across full width
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 280.w),
                  child: CenteredMarquee(
                    maxWidth: 280.w,
                    text: storyInfo == null ? "" : storyInfo!.storyName,
                    color: Colors.black,
                    fontSize: 24.w,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Channel / author line
              Row(
                children: [
                  ChannelImage(storyInfo!.channelImageUrl, storyInfo!.channelName, 48.w, 48.w),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storyInfo!.channelName, style: TextStyle(fontSize: 20.w)),
                      Row(
                        children: [
                          Avatar(storyInfo!.userId, storyInfo!.avatarUrl, 16.w),
                          SizedBox(width: 4.w),
                          Text(StringUtils.shorten(storyInfo!.nickname, 12), style: TextStyle(fontSize: 12.w)),
                          SizedBox(width: 8.w),
                          if (storyInfo!.collaboratorId.isNotEmpty)
                            Row(
                              children: [
                                Avatar(storyInfo!.collaboratorId, storyInfo!.collaboratorAvatarUrl, 16.w),
                                SizedBox(width: 4.w),
                                Text(StringUtils.shorten(storyInfo!.collaboratorName, 12), style: TextStyle(fontSize: 12.w)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}