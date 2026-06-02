import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/comment_controller.dart';

import '../../../dto/player_item_dto.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../services/toast_service.dart';
import '../providers.dart';

class InteractiveContentSwitch extends ConsumerWidget {
  final PlayerItemDto storyInfo;
  final CommentController commentController;

  InteractiveContentSwitch({required this.storyInfo, required this.commentController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool showInteractiveContent = false;
    if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId) {
      showInteractiveContent = ref.watch(isPlayingInteractiveContentProvider);
    } else {
      showInteractiveContent = ref.watch(isShowingInteractiveContentProvider);
    }

    if(!showInteractiveContent) {
      return Visibility(
        visible: ref.watch(interactiveMessageInfoListProvider) != null && ref.watch(interactiveMessageInfoListProvider)!.isNotEmpty,
        child: Positioned(
          bottom: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: () async {
              if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId) {
                actPodAudioHandler?.playFromIndex(1);
              }
              ref.watch(isShowingInteractiveContentProvider.notifier).state = true;
              commentController.clearInstantQueue();
            },
            child: Container(
              padding: EdgeInsets.only(left: 8.w, right: 4.w, top: 4.h, bottom: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xff222222).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "語音留言",
                    style: TextStyle(color: Colors.white, fontSize: 12.w),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12.w,
                  )
                ],
              ),
            ),
          )
        )
      );
    } else {
      return Visibility(
        visible: ref.watch(interactiveMessageInfoListProvider) != null && ref.watch(interactiveMessageInfoListProvider)!.isNotEmpty,
        child: Positioned(
          bottom: 8.h,
          left: 8.w,
          child: GestureDetector(
            onTap: () async {
              if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId) {
                actPodAudioHandler?.playFromIndex(0);
              }
              ref.watch(isShowingInteractiveContentProvider.notifier).state = false;
            },
            child: Container(
              padding: EdgeInsets.only(left: 4.w, right: 8.w, top: 4.h, bottom: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xff222222).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 12.w,
                  ),
                  Text(
                    "收聽正片",
                    style: TextStyle(color: Colors.white, fontSize: 12.w),
                  ),
                ],
              )
            ),
          ),
        )
      );
    }
  }
}