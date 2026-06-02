import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:quick_share_app/features/space_story_feature/components/story_card_item.dart';
import 'package:quick_share_app/features/space_story_feature/controllers/space_story_controller.dart';
import 'package:quick_share_app/features/space_story_feature/providers.dart';


class StoriesWall extends ConsumerWidget {
  final SpaceStoryController spaceStoryController;

  StoriesWall(this.spaceStoryController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceStories = ref.watch(spaceStoriesProvider);

    return LazyLoadScrollView(
      onEndOfPage: () {
        // boardStoryController.getMoreSpaceStories(spaceStories[0].spaceId);
      },
      scrollOffset: 1000,
      child: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: () async {},
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: spaceStories.length,
          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 0.h,),
          itemBuilder: (ctx, idx) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: StoryCardItem(idx, spaceStories, spaceStoryController)
            );
          },
        )
      )
    );
  }
}