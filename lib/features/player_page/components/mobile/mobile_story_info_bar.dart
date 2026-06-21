import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/content_rating_badge.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobiel_collect_button.dart';
import 'package:actpod_web/features/player_page/controllers/collection_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/centered_marquee.dart';
import '../../../../components/channel_image.dart';

class MobileStoryInfoBar extends ConsumerWidget {
  final CollectionController collectionController;

  MobileStoryInfoBar(this.collectionController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    if (storyInfo == null) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          // <-- makes the column take the available width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title line
              Align(
                alignment: Alignment.center, // centers across full width
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 320.w),
                  child: CenteredMarquee(
                    maxWidth: 320.w,
                    text: storyInfo.storyName,
                    color: Colors.black,
                    fontSize: 24.w,
                  ),
                ),
              ),
              // Channel / author line
              Row(
                children: [
                  ChannelImage(storyInfo.channelImageUrl, storyInfo.channelName,
                      48.w, 48.w),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storyInfo.channelName,
                          style: TextStyle(fontSize: 20.w)),
                      Row(
                        children: [
                          Avatar(storyInfo.userId, storyInfo.avatarUrl, 16.w),
                          SizedBox(width: 4.w),
                          Text(StringUtils.shorten(storyInfo.nickname, 12),
                              style: TextStyle(fontSize: 12.w)),
                          SizedBox(width: 8.w),
                          if (storyInfo.collaboratorId.isNotEmpty)
                            Row(
                              children: [
                                Avatar(storyInfo.collaboratorId,
                                    storyInfo.collaboratorAvatarUrl, 16.w),
                                SizedBox(width: 4.w),
                                Text(
                                    StringUtils.shorten(
                                        storyInfo.collaboratorName, 12),
                                    style: TextStyle(fontSize: 12.w)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  )),
                  CollectButton(collectionController: collectionController)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
