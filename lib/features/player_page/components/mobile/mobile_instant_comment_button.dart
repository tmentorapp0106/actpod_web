import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_list_model.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InstantCommentButton extends ConsumerWidget {
  final FocusNode focusNode;
  final CommentController commentController;
  final PlayerController playerController;
  final String storyId;

  InstantCommentButton({
    required this.focusNode,
    required this.commentController,
    required this.storyId,
    required this.playerController,
    // required this.storyInfo
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
                ? DesignColor.primary500.withOpacity(0.10)
                : null,
          ),
          onTap: () async {
            commentController.getInstantComments(storyId);
            await InstantCommentBottomModel(
              focusNode: focusNode,
              commentController: commentController,
              storyId: storyId,
              playerController: playerController
              // storyInfo: storyInfo
            ).show(context);
          },
          child: Ink( // Ink paints decoration so ripple is clipped correctly
            decoration: BoxDecoration(
              border: Border.all(color: DesignColor.primary500),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bubble_chart_rounded,
                    color: DesignColor.primary500,
                    size: 24.w
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "傳送即時留言",
                    style: TextStyle(
                      color: DesignColor.primary500,
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