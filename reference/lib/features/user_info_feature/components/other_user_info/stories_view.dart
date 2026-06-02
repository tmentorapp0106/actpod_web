import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';

import '../../../../apiManagers/story_api_dto/get_stories_by_userid_res.dart';
import '../../../../components/channel_image.dart';
import '../../../../design_system/design.dart';
import '../../../../dto/user_info_dto.dart';
import '../../../../main.dart';
import '../../../../providers.dart';
import '../../../../router.dart';
import '../../../../utils/time_utils.dart';

class StoriesView extends ConsumerWidget {
  StoriesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyList = ref.watch(otherStoryListProvider);
    final userInfoDto = ref.watch(otherUserInfoProvider);

    return Container(
      color: ConfigColor.background,
      child: storyList == null? emptyView() : storiesView(ref, storyList, userInfoDto)
    );
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
          SizedBox(height: 20.h,),
          Text(
            "No Stories yet",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      )
    );
  }

  Widget storiesView(WidgetRef ref, List<GetStoriesByUserIdResItem> storyList, UserInfoDto? otherUserInfo) {
    return Column(
      children:[
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: storyList.length,
            itemBuilder: (context, index) {
              return storyWidget(context, ref, storyList[index], index);
            }
          ),
        ),
      ]
    );
  }

  Widget storyWidget(BuildContext context, WidgetRef ref, GetStoriesByUserIdResItem story, int index) {
    return InkWell(
      onTap: () {
        List<PlayerItemDto> playerItemList = [PlayerItemDto.fromGetStoriesByUserIdResItem(story)];
        ref.watch(mainPlayerItemListProvider.notifier).state = playerItemList;
        ref.watch(loadingPlayerStoryInfoProvider.notifier).state = playerItemList[0];
        router.push("/story/multiple", extra: {"playerItemList": playerItemList, "index": 0});
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
            boxShadow: DesignSystem.shadow
        ),
        child: Stack(
            children: [
              Row(
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
                        )
                      )
                    )
                  ),
                  SizedBox(width: 5.w,),
                  SizedBox(
                      height: 150.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 165.w,
                              child: Text(
                                  story.storyName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: ConfigColor.textColorDefault,
                                      fontSize: 18.w,
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          ),
                          Row(
                              children: [
                                ChannelImage(story.channelImageUrl, story.channelName, 18.w, 12.w),
                                SizedBox(width: 2.w,),
                                SizedBox(
                                    width: 145.w,
                                    child: Marquee(
                                        animationDuration: const Duration(seconds: 10),
                                        directionMarguee: DirectionMarguee.oneDirection,
                                        child: Text(
                                            story.channelName,
                                            style: TextStyle(
                                                color: ConfigColor.textColorDefault,
                                                fontSize: 12.w
                                            )
                                        )
                                    )
                                ),
                              ]
                          ),
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
                                    SizedBox(width: 2.w,),
                                    Text(
                                      story.likesCount.toString(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DesignSystem.textColorGrey,
                                      ),
                                    ),
                                    SizedBox(width: 6.w,),
                                    SvgPicture.asset(
                                      "assets/icons/home_page/voice_chat.svg",
                                      width: 14.w,
                                      height: 14.w,
                                      color: DesignSystem.textColorGrey,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    SizedBox(width: 3.w,),
                                    Text(
                                      story.voiceMessageCount.toString(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DesignSystem.textColorGrey,
                                      ),
                                    )
                                  ]
                              )
                          ),
                          SizedBox(height: 5.h,),
                          SizedBox(
                              width: 165.w,
                              child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.w),
                                            color: Colors.black26.withOpacity(0.05)
                                        ),
                                        padding: EdgeInsets.only(left: 7.w, top: 2.h, right: 7.w, bottom: 4.h), // for Mandarin
                                        child: Text(
                                          story.spaceName,
                                          textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                          ),
                                        )
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                            children: [
                                              Text(
                                                TimeUtils.dayAgo(story.storyUploadTime),
                                                style: TextStyle(
                                                    fontSize: 12.w,
                                                    color: ConfigColor.textColorDefault
                                                ),
                                              ),
                                            ]
                                        ),
                                        SizedBox(
                                            height: 18.h,
                                            child: VerticalDivider(
                                              color: Colors.black,
                                              thickness: 1.w,
                                              width: 10.w,
                                            )
                                        ),
                                        Text(
                                          TimeUtils.formatDuration(Duration(milliseconds: story.totalLength), " HH:mm:ss"),
                                          style: TextStyle(
                                              fontSize: 12.w,
                                              color: ConfigColor.textColorDefault
                                          ),
                                        ),
                                        Icon(
                                            Icons.play_arrow_rounded,
                                            color: ConfigColor.primaryDefault,
                                            size: 20.w
                                        ),
                                      ],
                                    )
                                  ]
                              )
                          )
                        ],
                      )
                  )
                ],
              ),
            ]
        ),
      )
    );
  }
}