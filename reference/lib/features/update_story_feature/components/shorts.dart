import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/update_story_feature/controllers/shorts_controller.dart';
import 'package:quick_share_app/features/update_story_feature/provider.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/link_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../config/color.dart';
import '../../../dto/short_dto.dart';

class Shorts extends ConsumerWidget {
  final controller = TextEditingController();
  final ShortsController shortsController;
  final String storyId;

  Shorts({required this.shortsController, required this.storyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> shortWidgets = [];
    if(ref.watch(storyShortsProvider) == null) {
      shortWidgets = [];
    } else {
      for(ShortDto short in ref.watch(storyShortsProvider)!) {
        shortWidgets.add(shorts(short));
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Shorts",
                  style: TextStyle(
                    color: ConfigColor.textColorDefault,
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "綁定後，會在短影片區出現",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                final text = await showInputDialog(context);
                if (text == null || text.isEmpty) return;
                String? videoId = YoutubePlayer.convertUrlToId(text);
                if(videoId == null) {
                  ToastService.showNoticeToast("連結格式不正確");
                  return;
                }
                shortsController.createStoryShort(storyId, videoId);
              },
              child: Icon(
                Icons.add_circle_outline_rounded,
                size: 32.w,
                color: Colors.black,
              )
            )
          ]
        ),
        SizedBox(height: 8.h,),
        ref.watch(storyShortsProvider) == null? const Center(
          child: CircularProgressIndicator(
            color: DesignColor.actpodPrimary400,
          )
        ) : Column(
          children: shortWidgets,
        )
      ],
    );
  }

  Widget shorts(ShortDto short) {
    return GestureDetector(
      onTap: () {
        LinkUtils.onOpenShortsVideoId(short.videoId);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey
          ),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          children: [
            Text(short.videoId),
            const Spacer(),
            GestureDetector(
              onTap: () {
                shortsController.deleteStoryShort(storyId, short.shortId);
              },
              child: Icon(
                Icons.close,
                size: 20.w,
                color: Colors.black
              )
            )
          ],
        ),
      )
    );
  }

  Future<String?> showInputDialog(BuildContext context) async {
    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('請貼上 youtube shorts 連結'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '輸入...',
              focusColor: DesignColor.actpodPrimary400,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // 未聚焦顏色
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: DesignColor.actpodPrimary400, // 聚焦顏色
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(
                '確認',
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            ),
          ],
        );
      },
    );
    return result;
  }
}