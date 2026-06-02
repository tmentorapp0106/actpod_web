import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/instant_comment_bottom_model.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/comment_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../../../design_system/color.dart';
import '../../../main.dart';
import '../providers.dart';

class InstantCommentButton extends ConsumerWidget {
  final FocusNode focusNode;
  final CommentController commentController;
  final PlayerItemDto storyInfo;

  InstantCommentButton({
    required this.focusNode,
    required this.commentController,
    required this.storyInfo
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Material(
        color: Colors.transparent, // need a Material ancestor for ripples
        child: InkWell(
          borderRadius: BorderRadius.circular(10.w),
          splashFactory: InkRipple.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed)
                ? DesignColor.actpodPrimary500.withOpacity(0.10)
                : null,
          ),
          onTap: () async {
            final playerState = ref.watch(mainPlayerStatusProvider);
            await actPodAudioHandler?.pause();
            if(!context.mounted) {
              return;
            }
            commentController.getInstantComments(storyInfo.storyId);
            await InstantCommentBottomModel(
              focusNode: focusNode,
              commentController: commentController,
              storyInfo: storyInfo
            ).show(context);
            if(playerState == MainPlayerState.playing) {
              actPodAudioHandler?.play();
            }
          },
          child: Ink( // Ink paints decoration so ripple is clipped correctly
            decoration: BoxDecoration(
              border: Border.all(color: DesignColor.actpodPrimary500),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: SizedBox(
              height: 32.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bubble_chart_rounded,
                    color: DesignColor.actpodPrimary500,
                    size: 24.w
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "即時留言 ${ref.watch(instantCommentListProvider)?.length == null || ref.watch(instantCommentListProvider)!.isEmpty? "" : ref.watch(instantCommentListProvider)?.length.toString()}",
                    style: TextStyle(
                      color: DesignColor.actpodPrimary500,
                      fontSize: 14.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}