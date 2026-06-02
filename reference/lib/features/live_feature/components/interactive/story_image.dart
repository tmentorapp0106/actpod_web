import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../../design_system/color.dart';
import '../../providers.dart';

class StoryImage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);

    if (storyInfo == null) {
      return SizedBox(
        width: 80.w,
        height: 80.w,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DesignColor.actpodPrimary500,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.network(
            storyInfo!.storyImageUrl,
          )
        )
      )
    );
  }
}