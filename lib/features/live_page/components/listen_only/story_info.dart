import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/components/channel_image.dart';
import 'package:actpod_web/const.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoryInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);
    if(storyInfo == null) {
      return CircularProgressIndicator(
        strokeWidth: 2,
        color: DesignColor.actpodPrimary400,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            storyImage(storyInfo.storyImageUrl),
            const SizedBox(width: 8,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 252.w,
                  child: Builder(
                    builder: (context) {
                      final roomInfo = ref.watch(roomInfoProvider);

                      if (roomInfo == null) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: DesignColor.actpodPrimary500,
                            ),
                          ),
                        );
                      }

                      return Text(
                        roomInfo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4,),
                Row(
                  children: [
                    ChannelImage(
                      storyInfo.channelImageUrl,
                      storyInfo.channelName,
                      20,
                      12,
                      radius: 4,
                    ),
                    const SizedBox(width: 4,),
                    Text(storyInfo.channelName)
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 328.w,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '播放集數',
                        style: TextStyle(
                          color: const Color(0xFFF5A623),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          backgroundColor: const Color(0xFFFFF3D6),
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: storyInfo.storyName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        )
      ]
    );
  }
  
  Widget storyImage(String url) {
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.network(
            imgProxy + url,
            fit: BoxFit.cover,
            // customLoadingBuilder: (context, child, event) {
            //   return const Center(
            //     child: CircularProgressIndicator(
            //       strokeWidth: 2,
            //       color: DesignColor.primary50,
            //     ),
            //   );
            // },
          ),
        )
      )
    );
  }
}