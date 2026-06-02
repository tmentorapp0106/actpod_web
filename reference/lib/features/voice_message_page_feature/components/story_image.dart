import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../apiManagers/story_system_api_manager.dart';
import '../../../dto/player_item_dto.dart';
import '../../../router.dart';
import '../providers.dart';

class StoryImage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    return GestureDetector(
      onTap: () async {
        GetOneStoryRes response = await storyApiManager.getOneStory(storyInfo.storyId);
        if(response.code != "0000") {
          return;
        }
        if(response.story == null) {
          return;
        }
        List<PlayerItemDto> playList = [PlayerItemDto.fromGetOneStoryResItem(response.story!)];
        await router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          storyInfo!.storyImageUrl,
          width: 98.w,
          height: 98.w,
          fit: BoxFit.fitWidth,
        )
      )
    );
  }
}