import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/comment_controller.dart';
import 'package:quick_share_app/features/play_record_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/string_utils.dart';

import '../../../apiManagers/comment_api_dto/get_story_stat_res.dart';
import '../../../design_system/components/podcoin.dart';
import '../../../dto/player_item_dto.dart';
import '../../../providers.dart';
import '../../../utils/link_utils.dart';
import '../../login_feature/login_screen.dart';
import 'comment_bottom_model.dart';

class CommentSection extends ConsumerWidget {
  final CommentController commentController;
  final FocusNode focusNode;
  final PlayerItemDto storyInfo;
  
  CommentSection({
    required this.commentController,
    required this.focusNode,
    required this.storyInfo
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String countStr = "";
    if(ref.watch(storyStateProvider) != null && ref.watch(storyStateProvider)!.commentCount != 0) {
      countStr = "${ref.watch(storyStateProvider)!.commentCount} 則";
    }

    Widget contentWidget = loading();
    GetStoryStatResItem? storyStat = ref.watch(storyStateProvider);
    if(storyStat == null) {
      contentWidget = loading();
    } else if(storyStat.showedComment != null) {
      contentWidget = comment(
          storyStat.showedComment!.avatarUrl,
          storyStat.showedComment!.userId,
          storyStat.showedComment!.nickname,
          storyStat.showedComment!.content,
          storyStat.showedComment!.podcoins
      );
    } else {
      contentWidget = empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "文字留言",
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
                color: DesignColor.neutral950
              ),
            ),
            SizedBox(width: 8.w,),
            Text(
              countStr,
              style: TextStyle(
                fontSize: 12.w,
                color: DesignColor.neutral950
              ),
            )
          ],
        ),
        SizedBox(height: 8.h,),
        GestureDetector(
          onTap: () async {
            if(storyInfo == null || ref.watch(storyStateProvider) == null) {
              return;
            }
            if(!UserService.hasLoggedIn()) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return LoginPageScreen();
                  }
              );
              return;
            }
            ref.watch(isReplyModeProvider.notifier).state = false;
            commentController.getComments(storyInfo.storyId);
            await CommentBottomModel(
              commentController: commentController,
              focusNode: focusNode
            ).show(context, storyInfo.storyId, storyInfo.userId);
            ref.watch(commentListProvider.notifier).state = null;
            ref.watch(replyListProvider.notifier).state = null;
          },
          child: contentWidget
        )
      ],
    );
  }

  Widget loading() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DesignColor.neutral50,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DesignColor.primary50,
            strokeWidth: 4,
          )
        ],
      ),
    );
  }

  Widget comment(String avatarUrl, String userId, String name, String content, int podcoins) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DesignColor.neutral50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(userId, avatarUrl, 20.w),
          SizedBox(width: 8.w),
          Expanded( // <- makes the text area flexible horizontally
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      StringUtils.shorten(name, 20),
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.bold,
                        color: DesignColor.neutral950,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // optional: keep name on one line
                    ),
                    SizedBox(width: 4.w,),
                    Visibility(
                      visible: podcoins != 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.w),
                          color: DesignColor.secondary500
                        ),
                        child: Row(
                          children: [
                            PodCoin(size: 12.w),
                            SizedBox(width: 2,),
                            Text(
                              podcoins.toString(),
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            )
                          ],
                        )
                      )
                    )
                  ]
                ),
                SizedBox(height: 4.h),
                Text(
                  StringUtils.shorten(content, 50),
                  style: TextStyle(
                    fontSize: 12.w,
                    color: DesignColor.neutral950,
                  ),
                  softWrap: true,
                  textWidthBasis: TextWidthBasis.parent, // helps measure against the Expanded width
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget empty() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DesignColor.neutral50
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "留言",
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8.h,),
          Row(
            children: [
              Visibility(
                  visible: UserService.getUserInfo() != null,
                  child: Avatar(
                      null,
                      UserService.getUserInfo()?.avatarUrl,
                      20.w
                  )
              ),
              SizedBox(width: 8.w,),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: DesignColor.neutral30
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "說點什麼...",
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey
                            ),
                          )
                        ],
                      )
                  )
              )
            ],
          )
        ]
      )
    );
  }
}