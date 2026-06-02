import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/story_recommendation_dto.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/live_controller.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/record_wall_controller.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../../apiManagers/recommendation_api_dto/get_recommendation_res.dart';
import '../../../apiManagers/recommendation_api_dto/get_record_for_record_wall_res.dart'
    as another;
import '../providers.dart';
import 'recommendation_item.dart';

class RecordWallList extends ConsumerWidget {
  final RecordWallController _recordWallController;
  final LiveController _liveController;
  final Widget announcementWidget;

  RecordWallList(this._recordWallController, this._liveController, this.announcementWidget);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationList = ref.watch(recommendationListProvider);
    return LazyLoadScrollView(
      onEndOfPage: () => _recordWallController.getMoreRecommendations(),
      scrollOffset: 1000,
      child: _buildRecommendationList(ref, recommendationList),
    );
  }

  Widget _buildRecommendationList(
      WidgetRef ref, List<RecommendationItem> recordItemDtoList) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: Colors.black,
      onRefresh: () async {
        _recordWallController.refreshRecommendations();
        _liveController.getLiveRooms();
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) => SizedBox(height: 0.h,),
        itemCount: recordItemDtoList.length + 1, // +1 for the announcementWidget or loading indicator
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
              child: Text(
                "推薦內容",
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.bold
                ),
              )
            );
          }
          final itemIndex = idx - 1; // Adjust index for the actual list
          final isLast = itemIndex == recordItemDtoList.length - 1;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: RecommendationItemWidget(
              recordItemDtoList,
              recordItemDtoList[itemIndex],
              itemIndex,
              isLast
            ),
          );
        },
      ),
    );
  }
}
