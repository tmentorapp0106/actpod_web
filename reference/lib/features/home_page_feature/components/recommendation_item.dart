import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/story_card.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../dto/story_recommendation_dto.dart';
import '../../../providers.dart';

class RecommendationItemWidget extends ConsumerWidget {
  final List<RecommendationItem> recommendationList;
  final RecommendationItem recordItem;
  final int index;
  final bool isLast;

  RecommendationItemWidget(this.recommendationList, this.recordItem, this.index, this.isLast);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      children: [
        StoryCard(index, recommendationItem: recordItem, previewPlayFunction: previewPlayerController.previewPlayFunction),
        isLast? SizedBox(height: 120.h,) : const SizedBox.shrink()
      ]
    );
  }
}
