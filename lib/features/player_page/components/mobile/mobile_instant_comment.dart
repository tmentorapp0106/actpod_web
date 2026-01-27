import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/components/timed_fade.dart';
import 'package:actpod_web/dto/comment_dto.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../design_system/color.dart';

class MobileInstantComment extends ConsumerWidget {
  final String commentKey;
  final int index;
  final double? top;
  final double? left;
  final double? right;
  final double? from;
  final double? to;
  final InstantCommentInfoDto commentInfo;
  final CommentController commentController;

  MobileInstantComment({required this.commentController, required this.commentKey, required this.commentInfo, required this.index, this.top, this.left, this.right, this.from, this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final startDyPx = (340.w - top! + 100).clamp(0, double.infinity).toDouble();
          return TimedSlideFromBottomFadeOut(
            key: ValueKey(commentKey),
            startDyPx: startDyPx,
            slideIn: const Duration(milliseconds: 300),
            hold: const Duration(seconds: 5),
            fadeOut: const Duration(milliseconds: 300),
            onComplete: () async {
              while(commentController.isProcessingInstantComment) {
                await Future.delayed(const Duration(milliseconds: 200));
              }
              if(ref.watch(playContentProvider) == PlayContent.interactiveContent) { // 不然會妨礙清除 comment queue
                return;
              }
              List<Widget> widgets = ref.read(instantCommentWidgets);
              widgets[index] = const SizedBox.shrink();
              ref.watch(instantCommentWidgets.notifier).state = [...widgets];
              instantCommentPositionQueue.removeFirst();
            },
            child: Container(
              width: 150.w,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: DesignColor.neutral50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Avatar(commentInfo.userId, commentInfo.avatarUrl, 18.w),
                      SizedBox(width: 8.w),
                      Text(
                        StringUtils.shorten(commentInfo.nickname, 8),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.w
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Visibility(
                    visible: commentInfo.podcoins != 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(10.w),
                        color: DesignColor.secondary500,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PodCoin(size: 12.w),
                          const SizedBox(width: 2),
                          Text(
                            commentInfo.podcoins.toString(),
                            style: const TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    commentInfo.content,
                    softWrap: true,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.w),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}