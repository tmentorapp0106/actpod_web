import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/features/player_page/service/redirect.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileComment extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget contentWidget = loading();
    GetStoryStatResItem? storyStat = ref.watch(storyStateProvider);
    if(storyStat == null) {
      contentWidget = loading();
    } else if(storyStat.showedComment != null) {
      contentWidget = comment(
          storyStat.showedComment!.avatarUrl,
          storyStat.showedComment!.userId,
          storyStat.showedComment!.nickname,
          storyStat.showedComment!.content
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
          ],
        ),
        SizedBox(height: 8.h,),
        GestureDetector(
          onTap: () async {
            await RedirectService.toDownload();
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

  Widget comment(String avatarUrl, String userId, String name, String content) {
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
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.w,
                    fontWeight: FontWeight.bold,
                    color: DesignColor.neutral950,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // optional: keep name on one line
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