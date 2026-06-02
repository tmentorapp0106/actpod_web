import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/features/search_page_feature/controllers/preview_play_controller.dart';
import 'package:quick_share_app/features/search_page_feature/components/empty_view.dart';

import '../../../apiManagers/channel_api_dto/search_channel_res.dart';
import '../../../apiManagers/story_api_dto/search_stories_res.dart';
import '../../../config/color.dart';
import '../../../design_system/design.dart';
import '../../../dto/player_item_dto.dart';
import '../../../dto/user_info_dto.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../router.dart';
import '../../../services/player_service.dart';
import '../../../utils/time_utils.dart';
import '../providers.dart';

class SearchResultList extends ConsumerWidget {
  final PreviewPlayController preivewPlayController;
  final TextEditingController searchTextController;
  SearchResultList(this.preivewPlayController, this.searchTextController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(searchTypeProvider) == "story") {
      return storyList(ref, preivewPlayController);
    } else if (ref.watch(searchTypeProvider) == "channel") {
      return channelList(ref);
    } else {
      return userList(ref);
    }
  }

  Widget channelList(WidgetRef ref) {
    final channelItemList = ref.watch(searchChannelItemListProvider);
    if (channelItemList == null || channelItemList.isEmpty) {
      return SliverToBoxAdapter(child: EmptyView(type: 'channel',textController: searchTextController));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: channelItemList == null ? 0 : channelItemList.length,
        (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            child: channelItemWidget(channelItemList![index]),
          );
        },
      ),
    );
  }

  Widget channelItemWidget(SearchChannelItem channelInfo) {
    return GestureDetector(
        onTap: () {
          router.push("/channel/${channelInfo.channelId}");
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    height: 90.w,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          child: SizedBox(
                            width: 64.w,
                            height: 64.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.w),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: channelInfo.channelImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 4,
                                          sigmaY: 4), // Adjust blur intensity
                                      child: Container(
                                        color: Colors
                                            .transparent, // Keep it transparent to apply only the blur effect
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: SizedBox(
                              width: 72.w,
                              height: 72.w,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.w),
                                  child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: CachedNetworkImage(
                                        imageUrl: channelInfo.channelImageUrl,
                                      )))),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channelInfo.channelName,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "頻道",
                            style: TextStyle(
                                fontSize: 12.w,
                                color: ConfigColor.textColorDefault),
                          ),
                          SizedBox(
                              height: 18.h,
                              child: VerticalDivider(
                                color: Colors.black,
                                thickness: 1.w,
                                width: 10.w,
                              )),
                          Text(
                            channelInfo.nickname,
                            style: TextStyle(
                                fontSize: 12.w,
                                color: ConfigColor.textColorDefault),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ))
          ],
        ));
  }

  Widget userList(WidgetRef ref) {
    final searchUserItemList = ref.watch(searchUserItemListProvider);
    if (searchUserItemList == null || searchUserItemList.isEmpty) {
      return SliverToBoxAdapter(child: EmptyView(type: 'user',textController:searchTextController));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: searchUserItemList == null ? 0 : searchUserItemList.length,
        (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            child: userItemWidget(searchUserItemList![index]),
          );
        },
      ),
    );
  }

  Widget userItemWidget(UserInfoDto userInfo) {
    return InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () {
          router.push("/otherUserInfo/${userInfo.userId}");
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Avatar(userInfo.userId, userInfo.avatarUrl, 80.w),
                  SizedBox(
                    width: 8.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userInfo.nickname,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold)),
                      Text(
                        "Podcaster",
                        style:
                            TextStyle(color: Color(0xff8f8f8f), fontSize: 12.w),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ))
          ],
        ));
  }

  Widget storyList(WidgetRef ref, PreviewPlayController autoPlayController) {
    final searchStoriesItemList = ref.watch(searchStoriesItemListProvider);
    if (searchStoriesItemList == null || searchStoriesItemList.isEmpty) {
      return SliverToBoxAdapter(child: EmptyView(type: 'story',textController: searchTextController));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount:
            searchStoriesItemList == null ? 0 : searchStoriesItemList.length,
        (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            child: storyItemWidget(
              ref,
              autoPlayController,
              searchStoriesItemList!,
              index,
            ),
          );
        },
      ),
    );
  }

  Widget storyItemWidget(
      WidgetRef ref,
      PreviewPlayController autoPlayController,
      List<SearchStoriesResItem> searchStoriesItemList,
      int index) {
    return GestureDetector(
        onTap: () {
          autoPlayController.pausePreview();
          ref.watch(searchPreviewIndexProvider.notifier).state = null;
          List<PlayerItemDto> playList = [
            PlayerItemDto.fromSearchStoriesResItem(searchStoriesItemList[index])
          ];
          router.push("/story/multiple",
              extra: {"playerItemList": playList, "index": 0});
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        preivewPlayController.playPause(index);
                      },
                      child: SizedBox(
                          width: 80.w,
                          height: 80.w,
                          child: Stack(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(16.w),
                                child: AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: CachedNetworkImage(
                                      imageUrl: searchStoriesItemList[index]
                                          .storyImageUrl,
                                    ))),
                            Positioned(
                                bottom: 4.w,
                                left: 0,
                                right: 0,
                                child: Center(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6.w),
                                            color: Color(0xff222222)
                                                .withOpacity(0.5)),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                ref.watch(searchPreviewPlayStatusProvider) ==
                                                            "playing" &&
                                                        ref.watch(
                                                                searchPreviewIndexProvider) ==
                                                            index
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 16.w,
                                              ),
                                              Text(
                                                "試聽精華",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.w),
                                              ),
                                            ]))))
                          ]))),
                  SizedBox(
                    width: 8.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            TimeUtils.dayAgo(
                                searchStoriesItemList[index].storyUploadTime),
                            style: TextStyle(
                                fontSize: 12.w,
                                color: ConfigColor.textColorDefault),
                          ),
                          SizedBox(
                              height: 18.h,
                              child: VerticalDivider(
                                color: Colors.black,
                                thickness: 1.w,
                                width: 10.w,
                              )),
                          Text(
                            TimeUtils.formatDuration(
                                Duration(
                                    milliseconds: searchStoriesItemList[index]
                                        .totalLength),
                                " HH:mm:ss"),
                            style: TextStyle(
                                fontSize: 12.w,
                                color: ConfigColor.textColorDefault),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      SizedBox(
                        width: 220.w,
                        child: Marquee(
                            animationDuration: const Duration(seconds: 10),
                            directionMarguee: DirectionMarguee.oneDirection,
                            child: AutoSizeText(
                                searchStoriesItemList[index].storyName,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.w,
                                    fontWeight: FontWeight.bold))),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w),
                                  color: Colors.black26.withOpacity(0.05)),
                              padding: EdgeInsets.only(
                                  left: 10.w,
                                  top: 2.h,
                                  right: 10.w,
                                  bottom: 4.h), // for Mandarin
                              child: Text(
                                searchStoriesItemList[index].spaceName,
                                style: TextStyle(
                                  fontSize: 12.w,
                                ),
                              )),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            searchStoriesItemList[index].username,
                            style: TextStyle(
                                fontSize: 12.w, color: Color(0xff8f8f8f)),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ))
          ],
        ));
  }
}
