import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../config/color.dart';
import '../../../dto/comment_dto.dart';
import '../../../providers.dart';
import '../controllers/comment_controller.dart';
import '../controllers/player_controller.dart';
import '../providers.dart';

class PlayerProgressBar extends ConsumerWidget {
  final PlayerController cardPlayerController;
  final CommentController commentController;
  final PlayerItemDto storyInfo;

  PlayerProgressBar(this.cardPlayerController, this.commentController, this.storyInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seekPosition = storyInfo.storyId == ref.watch(mainPlayerStoryInfoProvider)?.storyId && ref.watch(mainPlayerStatusProvider) != MainPlayerState.initiating? ref.watch(mainPlayerPositionProvider) : Duration.zero;
    int totalLength = 0;

    if(storyInfo.storyId == actPodAudioHandler?.mediaItem.value?.id) {
      totalLength = ref.watch(mainPlayerLengthProvider).inMilliseconds;
    } else if (ref.watch(isShowingInteractiveContentProvider)) {
      totalLength = ref.read(interactiveMessageInfoListProvider)?.last.toMilliSec?? 0;
    } else {
      totalLength = storyInfo.totalLength;
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 320.w,
              height: 16.w,
              child: ProgressBar(
                progress: seekPosition,
                thumbRadius: 6.w,
                barHeight: 4.w,
                thumbColor: DesignColor.primary50,
                baseBarColor: Color(0xFFd6d6d6),
                progressBarColor: DesignColor.primary50,
                total: Duration(milliseconds: totalLength),
                onSeek: (duration) async {
                  while(commentController.isProcessingInstantComment) {
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                  List<InstantCommentInfoDto>? commentList = ref.watch(instantCommentListProvider);
                  commentList?.addAll(instantCommentSendList);
                  instantCommentSendList.clear();
                  ref.watch(instantCommentListProvider.notifier).state = [...?commentList];
                  cardPlayerController.seekAudioPosition(duration);
                },
                timeLabelLocation: TimeLabelLocation.none,
                timeLabelTextStyle: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 12.sp
                )
              )
            ),
          ]
        ),
        SizedBox(
          width: 328.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeUtils.formatDuration(seekPosition, "HH:mm:ss"),
                style: TextStyle(
                    fontSize: 12.w
                ),
              ),
              Text(
                TimeUtils.formatDuration(Duration(milliseconds: totalLength), "HH:mm:ss"),
                style: TextStyle(
                  fontSize: 12.w
                ),
              )
            ],
          )
        )
      ]
    );
  }
}