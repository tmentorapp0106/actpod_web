import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/interactive_content_indicator.dart';
import 'package:quick_share_app/features/play_record_feature/components/interactive_content_switch.dart';
import 'package:quick_share_app/features/play_record_feature/components/story_image.dart';

import '../../../main.dart';
import '../../../providers.dart';
import '../controllers/comment_controller.dart';
import '../providers.dart';

class ImageInstantComment extends ConsumerWidget {
  final PlayerItemDto storyInfo;
  final CommentController commentController;

  const ImageInstantComment({super.key, required this.storyInfo, required this.commentController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool showInteractiveContent = false;
    if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId) {
      showInteractiveContent = ref.watch(isPlayingInteractiveContentProvider);
    } else {
      showInteractiveContent = ref.watch(isShowingInteractiveContentProvider);
    }
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            showInteractiveContent? InteractiveContentIndicator() : StoryImage(storyInfo: storyInfo),
          ],
        ),
        Visibility(
          visible: !ref.watch(isPlayingInteractiveContentProvider) && actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId,
          child: Positioned.fill(
            child: IgnorePointer(
              ignoring: false, // comments are decorative; remove if tappable
              child: ClipRect(
                child: Stack(children: ref.watch(instantCommentWidgets)),
              ),
            ),
          )
        ),
        InteractiveContentSwitch(storyInfo: storyInfo, commentController: commentController,),
      ],
    );
  }
}