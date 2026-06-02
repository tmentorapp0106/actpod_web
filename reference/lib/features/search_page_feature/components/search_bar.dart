import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/search_page_feature/controllers/preview_play_controller.dart';
import 'package:quick_share_app/features/search_page_feature/providers.dart';

import '../../../providers.dart';
import '../../../router.dart';
import '../controllers/search_controller.dart';

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final SearchItemController searchStoriesController;
  final TextEditingController textController;
  final PreviewPlayController previewPlayController;
  final FocusNode searchFocusNode;
  final double height;

  SearchBarDelegate(this.height, this.searchStoriesController,
      this.textController, this.previewPlayController, this.searchFocusNode);

  @override
  double get minExtent => height; // Minimum height when collapsed
  @override
  double get maxExtent => height; // Maximum height when expanded

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchContentBar(searchStoriesController, textController, previewPlayController, searchFocusNode)
        ]
      )
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class SearchContentBar extends ConsumerWidget {
  final SearchItemController searchController;
  final TextEditingController textController;
  final PreviewPlayController previewPlayController;
  final FocusNode searchFocusNode;

  SearchContentBar(this.searchController, this.textController,
      this.previewPlayController, this.searchFocusNode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActivate = ref.watch(isTextingProvider) ||
        ref.watch(searchStoriesItemListProvider) != null;
    return Container(
        margin: EdgeInsets.only(top: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 24.w),
                  onPressed: () {
                    router.pop();
                  },
                ),
                searchBar(ref, isActivate),
              ],
            ),
            ref.watch(searchStoriesItemListProvider) == null &&
                    ref.watch(searchUserItemListProvider) == null &&
                    ref.watch(searchChannelItemListProvider) == null
                ? SizedBox.shrink()
                : tags(ref)
          ],
        ));
  }

  Widget tags(WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, top: 12.h, bottom: 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              previewPlayController.pausePreview();
              ref.watch(searchTypeProvider.notifier).state = "story";
              if (ref.watch(searchTextProvider) == "") {
                return;
              }
              searchController.searchStories(ref.watch(searchTextProvider));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                  color: ref.watch(searchTypeProvider) == "story"
                      ? ConfigColor.primaryDefault
                      : const Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(16.w)),
              child: Text(
                "故事",
                style: TextStyle(
                  fontSize: 16.w,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          GestureDetector(
            onTap: () {
              previewPlayController.pausePreview();
              ref.watch(searchTypeProvider.notifier).state = "channel";
              if (ref.watch(searchTextProvider) == "") {
                return;
              }
              searchController.searchChannel(ref.watch(searchTextProvider));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                  color: ref.watch(searchTypeProvider) == "channel"
                      ? ConfigColor.primaryDefault
                      : const Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(16.w)),
              child: Text(
                "頻道",
                style: TextStyle(
                  fontSize: 16.w,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          GestureDetector(
            onTap: () {
              previewPlayController.pausePreview();
              ref.watch(searchTypeProvider.notifier).state = "podcaster";
              if (ref.watch(searchTextProvider) == "") {
                return;
              }
              searchController.searchUser(ref.watch(searchTextProvider));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                  color: ref.watch(searchTypeProvider) == "podcaster"
                      ? ConfigColor.primaryDefault
                      : const Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(16.w)),
              child: Text(
                "Podcaster",
                style: TextStyle(
                  fontSize: 16.w,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget searchBar(WidgetRef ref, bool isActivate) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: isActivate ? 284.w : 320.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Color(0xfff2f2f2),
            borderRadius: BorderRadius.circular(11.w),
          ),
          child: Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: ref.watch(localeProvider) == const Locale('zh')
                          ? 4.5.h
                          : 0),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20.w,
                  )),
              SizedBox(
                width: 2.w,
              ),
              Expanded(
                  child: TextField(
                focusNode: searchFocusNode,
                controller: textController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isEmpty) {
                    return;
                  }
                  if (ref.watch(searchTypeProvider) == "story") {
                    searchController.searchStories(value);
                  } else if (ref.watch(searchTypeProvider) == "podcaster") {
                    searchController.searchUser(value);
                  } else {
                    searchController.searchChannel(value);
                  }
                },
                decoration: InputDecoration(
                    hintText: "搜尋故事名稱及 podcaster",
                    hintStyle: TextStyle(fontSize: 14.w, color: Colors.grey),
                    contentPadding: EdgeInsets.all(0.h),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    isDense: true,
                    isCollapsed: true),
              )),
              ref.watch(searchTextProvider) != ""
                  ? GestureDetector(
                      onTap: () {
                        textController.text = "";
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xff8f8f8f),
                            shape: BoxShape.circle, // Makes it a perfect circle
                          ),
                          padding: EdgeInsets.all(2.w),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20.w,
                          )))
                  : const SizedBox.shrink(),
            ],
          )),
      isActivate
          ? SizedBox(
              width: 8.w,
            )
          : const SizedBox.shrink(),
      isActivate
          ? InkWell(
              onTap: () {
                ref.watch(searchStoriesItemListProvider.notifier).state = null;
                ref.watch(searchChannelItemListProvider.notifier).state = null;
                ref.watch(searchUserItemListProvider.notifier).state = null;
                previewPlayController.pausePreview();
                textController.text = "";
                searchFocusNode.unfocus();
              },
              child: Text(
                "取消",
                style: TextStyle(fontSize: 16.w),
              ),
            )
          : const SizedBox.shrink()
    ]);
  }
}
