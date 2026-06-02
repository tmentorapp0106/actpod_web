import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_collection_feature/providers.dart';

import '../../../components/story_card.dart';
import '../../../controllers/preview_controller.dart';
import '../../../design_system/color.dart';

class StoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(collectionStoryListProvider);
    if (stories == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding:  EdgeInsets.only(top: 24),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DesignColor.actpodPrimary400,
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.only(bottom: 24.h),
      sliver: SliverList.separated(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: StoryCard(
              index,
              recommendationItem: stories[index],
              previewPlayFunction: previewPlayerController.previewPlayFunction,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
      ),
    );
  }
}