import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/features/user_info_feature/components/story_bottom_sheet.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/color_utils.dart';

import '../../../apiManagers/story_api_dto/get_stories_by_userid_res.dart';
import '../../../components/avatar.dart';
import '../../../components/channel_image.dart';
import '../../../dto/user_info_dto.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../router.dart';
import '../../../utils/time_utils.dart';
import '../controllers/download_controller.dart';
import '../controllers/story_controller.dart';

class StoriesView extends ConsumerWidget {
  final bool _viewingOthers;
  final StoryController _storyController;
  final DownloadController _downloadController;

  StoriesView(
      this._viewingOthers, this._storyController, this._downloadController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyList = ref.watch(selfStoryListProvider);
    final userInfoDto = ref.watch(selfUserInfoProvider);

    return Container(
        color: ConfigColor.background,
        child: Column(
          children: [
            ref.watch(syncProcessingProvider)
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("RSS 同步處理中..."))
                : const SizedBox.shrink(),
            storyList == null || storyList.isEmpty
                ? emptyView()
                : Expanded(child: storiesView(ref, storyList, userInfoDto))
          ],
        ));
  }

  Widget emptyView() {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/images/empty_stories.svg",
          width: 100.w,
          height: 100.w,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          height: 20.h,
        ),
        Text(
          "No Stories yet",
          style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        )
      ],
    ));
  }

  Widget storiesView(WidgetRef ref, List<GetStoriesByUserIdResItem> storyList,
      UserInfoDto? otherUserInfo) {
    final sortedStoryList = [...storyList]..sort((a, b) {
        final aProcessing = _isProcessingStory(a);
        final bProcessing = _isProcessingStory(b);
        if (aProcessing == bProcessing) return 0;
        return aProcessing ? -1 : 1;
      });

    return Column(children: [
      Expanded(
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: sortedStoryList.length,
            itemBuilder: (context, index) {
              final story = sortedStoryList[index];
              return Stack(
                children: [
                  storyWidget(context, ref, story, index),
                  more(context, story),
                  processing(story),
                  verifying(story),
                  reject(story),
                  scheduling(story)
                ],
              );
            }),
      ),
      SizedBox(
        height: 64.h,
      ),
    ]);
  }

  bool _isProcessingStory(GetStoriesByUserIdResItem story) {
    return story.storyUrl == "" || story.review.status == "processing";
  }

  Widget more(BuildContext context, GetStoriesByUserIdResItem story) {
    return Positioned(
        right: 16.w,
        top: 8.h,
        child: GestureDetector(
          onTap: () async {
            bool? update = await showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.w))),
                builder: (context) {
                  return StoryBottomSheet(
                      story, _storyController, _downloadController);
                });
            if (update != null && update) {
              _storyController.getStories(UserService.getUserInfo()!.userId);
              _storyController.getStoryCount(UserService.getUserInfo()!.userId);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(Icons.more_vert_rounded),
          ),
        ));
  }

  Widget processing(GetStoriesByUserIdResItem story) {
    return Visibility(
        visible: story.storyUrl == "",
        child: Container(
            height: 178.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.w)),
            child: const Center(
              child: Text(
                "處理中",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )));
  }

  Widget verifying(GetStoriesByUserIdResItem story) {
    return Visibility(
        visible: story.storyUrl != "" && story.review.status == "pending",
        child: Container(
            height: 178.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.w)),
            child: const Center(
              child: Text(
                "審核中",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )));
  }

  Widget scheduling(GetStoriesByUserIdResItem story) {
    return Visibility(
        visible: story.review.status == "pass" &&
            story.releaseTime.toUtc().isAfter(DateTime.now().toUtc()),
        child: Container(
            height: 178.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.w)),
            child: Center(
              child: Text(
                "將於 ${TimeUtils.convertToFormat("yyyy/MM/dd hh:mm", story.releaseTime.toLocal())} 上架",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )));
  }

  Widget reject(GetStoriesByUserIdResItem story) {
    return Visibility(
        visible: story.storyUrl != "" && story.review.status == "reject",
        child: Container(
            height: 178.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.w)),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                "不通過",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text(
                "原因：${story.review.reason}",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ]))));
  }

  Widget createStory(BuildContext context) {
    return InkWell(
        onTap: () {
          router.push("/record");
        },
        child: Container(
            width: 500.w,
            height: 500.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey, Colors.white.withOpacity(0), Colors.grey],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                Icons.add,
                size: 40.w,
              ),
              Text(
                "新增故事",
                style: TextStyle(fontSize: 10.w),
              )
            ]))));
  }

  Widget storyWidget(BuildContext context, WidgetRef ref,
      GetStoriesByUserIdResItem story, int index) {
    String lockedString = "";
    if (story.locked) {
      lockedString = "(已上鎖)";
    }
    return InkWell(
      onTap: () {
        if (story.storyUrl == "" ||
            (story.storyUrl != "" && story.review.status == "pending")) { 
          return;
        }
        List<PlayerItemDto> playerItemList = [
          PlayerItemDto.fromGetStoriesByUserIdResItem(story)
        ];
        router.push("/story/multiple",
            extra: {"playerItemList": playerItemList, "index": 0});
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
        decoration: BoxDecoration(
            color: Color(0xfffefefe),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(
              color: DesignSystem.borderGrey,
            ),
            boxShadow: DesignSystem.shadow),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 150.w,
                height: 150.w,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.w),
                    child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: CachedNetworkImage(
                          imageUrl: story.storyImageUrl,
                        )))),
            SizedBox(
              width: 5.w,
            ),
            SizedBox(
                height: 150.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 165.w,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: lockedString,
                              style: TextStyle(
                                color: Colors
                                    .red, // 👈 different color for lockedString
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: story.storyName,
                              style: TextStyle(
                                color: ConfigColor.textColorDefault,
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(children: [
                      ChannelImage(
                          story.channelImageUrl, story.channelName, 18.w, 12.w),
                      SizedBox(
                        width: 2.w,
                      ),
                      SizedBox(
                          width: 145.w,
                          child: Marquee(
                              animationDuration: const Duration(seconds: 10),
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(story.channelName,
                                  style: TextStyle(
                                      color: ConfigColor.textColorDefault,
                                      fontSize: 12.w)))),
                    ]),
                    const Spacer(),
                    SizedBox(
                        width: 160.w,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/home_page/favorite.svg",
                                width: 14.w,
                                height: 14.w,
                                fit: BoxFit.fitWidth,
                                color: DesignSystem.textColorGrey,
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              Text(
                                story.likesCount.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignSystem.textColorGrey,
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              SvgPicture.asset(
                                "assets/icons/home_page/voice_chat.svg",
                                width: 14.w,
                                height: 14.w,
                                color: DesignSystem.textColorGrey,
                                fit: BoxFit.fitWidth,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                story.voiceMessageCount.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignSystem.textColorGrey,
                                ),
                              )
                            ])),
                    SizedBox(
                      height: 5.h,
                    ),
                    SizedBox(
                        width: 165.w,
                        child: Row(children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w),
                                  color: Colors.black26.withOpacity(0.05)),
                              padding: EdgeInsets.only(
                                  left: 7.w,
                                  top: 2.h,
                                  right: 7.w,
                                  bottom: 4.h), // for Mandarin
                              child: Text(
                                story.spaceName,
                                textScaleFactor:
                                    1 / MediaQuery.of(context).textScaleFactor,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                ),
                              )),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(children: [
                                Text(
                                  TimeUtils.dayAgo(story.storyUploadTime),
                                  style: TextStyle(
                                      fontSize: 12.w,
                                      color: ConfigColor.textColorDefault),
                                ),
                              ]),
                              SizedBox(
                                  height: 18.h,
                                  child: VerticalDivider(
                                    color: Colors.black,
                                    thickness: 1.w,
                                    width: 10.w,
                                  )),
                              Text(
                                TimeUtils.formatDuration(
                                    Duration(milliseconds: story.totalLength),
                                    " HH:mm:ss"),
                                style: TextStyle(
                                    fontSize: 12.w,
                                    color: ConfigColor.textColorDefault),
                              ),
                              Icon(Icons.play_arrow_rounded,
                                  color: ConfigColor.primaryDefault,
                                  size: 20.w),
                            ],
                          )
                        ]))
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
