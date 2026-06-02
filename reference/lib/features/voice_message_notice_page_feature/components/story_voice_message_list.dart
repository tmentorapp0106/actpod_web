import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/components/story_empty_view.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../config/color.dart';
import '../../../dto/voice_message_notice_dto.dart';
import '../../../router.dart';
import '../../user_info_feature/screens/other_user_info_screen.dart';

class StoryVoiceMessageList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<VoiceMessageNoticeDto> voiceMessageNoticeList = ref.watch(storyVoiceMessageNoticeListProvider);
    if (voiceMessageNoticeList.isEmpty) {
      return StoryEmptyView();
    }
    else{
    return ListView.separated(
      padding: EdgeInsets.only(top: 12.h),
      itemCount: ref.watch(mainPlayerStoryInfoProvider) == null? voiceMessageNoticeList.length : voiceMessageNoticeList.length + 1,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if(index == voiceMessageNoticeList.length) {// mini player
          return SizedBox(height: 54.h,);
        }

        VoiceMessageNoticeDto dto = voiceMessageNoticeList[index];
        if((dto.noticeType == "storyOwner" || dto.noticeType == "collaborator") && dto.lastResponseUserType == "listener" && dto.lastAction == "new" && dto.donateAmount != 0) {
          return gotDonation(context, dto);
        } else if((dto.noticeType == "storyOwner" || dto.noticeType == "collaborator") && dto.lastResponseUserType == "listener" && dto.lastAction == "new") {
          return gotNewMessage(context, dto);
        } else if((dto.noticeType == "storyOwner" || dto.noticeType == "collaborator") && dto.lastResponseUserType == "listener" && dto.lastAction == "response") {
          return gotNewMessage(context, dto);
        } else if((dto.noticeType == "storyOwner" || dto.noticeType == "collaborator") && (dto.lastResponseUserType == "storyOwner" ||  dto.lastResponseUserType == "collaborator") && dto.lastAction == "response") {
          return responseListenerMessage(context, dto);
        } else if((dto.noticeType == "storyOwner" || dto.noticeType == "collaborator") && dto.lastAction == "add") {
          return addedListenerMessage(context, dto);
        }
        return gotNewMessage(context, voiceMessageNoticeList[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 8.h,);
      },
    );}
  }

  Widget addedListenerMessage(BuildContext context, VoiceMessageNoticeDto dto) {
    return GestureDetector(
      onTap: () {
        String collaboratorIdParam = dto.collaboratorId == ""? "null" : dto.collaboratorId;
        router.push("/voiceMessage/story/${dto.storyId}/owner/${dto.storyOwnerId}/collaborator/$collaboratorIdParam");
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: DesignSystem.shadow
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "你將一則留言加入故事中",
                  style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.timeAgo(dto.updateTime),
                  style: TextStyle(
                    fontSize: 12.sp
                  ),
                )
              ],
            ),
            SizedBox(height: 4.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "來自",
                  style: TextStyle(
                    fontSize: 12.w,
                  ),
                ),
                SizedBox(width: 8.w,),
                Avatar(dto.lastVoiceMessageSenderId, dto.lastVoiceMessageAvatarUrl, 18.w),
                SizedBox(width: 4.w,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return OtherUserInfoScreen(dto.lastVoiceMessageSenderId);
                    }));
                  },
                  child: Text(
                    StringUtils.shorten(dto.lastVoiceMessageSenderName, 8),
                    style: TextStyle(
                      fontSize: 12.w,
                      color: DesignColor.info,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8.w,),
                Text(
                  "的語音留言",
                  style: TextStyle(
                      fontSize: 12.w
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.network(
                        dto.storyImageUrl,
                      )
                    )
                  )
                ),
                SizedBox(width: 8.w,),
                SizedBox(
                  height: 60.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 240.w,
                        child: Text(
                          dto.storyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ConfigColor.textColorDefault,
                            fontSize: 12.w
                          )
                        )
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildChannelImage(dto.channelImageUrl, dto.channelName),
                          SizedBox(width: 2.w,),
                          Marquee(
                            animationDuration: const Duration(seconds: 10),
                            directionMarguee: DirectionMarguee.oneDirection,
                            child: Text(
                              dto.channelName,
                              style: TextStyle(
                                color: ConfigColor.textColorDefault,
                                fontSize: 12.w
                              )
                            )
                          )
                        ],
                      ),
                      const Spacer(),
                    ],
                  )
                )
              ],
            )
          ],
        ),
      )
    );
  }

  Widget responseListenerMessage(BuildContext context, VoiceMessageNoticeDto dto) {
    return GestureDetector(
      onTap: () {
        String collaboratorIdParam = dto.collaboratorId == ""? "null" : dto.collaboratorId;
        router.push("/voiceMessage/story/${dto.storyId}/owner/${dto.storyOwnerId}/collaborator/$collaboratorIdParam");
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: DesignSystem.shadow
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "你或共同創作者回覆了留言",
                  style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.timeAgo(dto.updateTime),
                  style: TextStyle(
                    fontSize: 12.sp
                  ),
                )
              ],
            ),
            SizedBox(height: 4.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "來自",
                  style: TextStyle(
                    fontSize: 12.w,
                  ),
                ),
                SizedBox(width: 8.w,),
                Avatar(dto.lastVoiceMessageSenderId, dto.lastVoiceMessageAvatarUrl, 18.w),
                SizedBox(width: 4.w,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return OtherUserInfoScreen(dto.lastVoiceMessageSenderId);
                    }));
                  },
                  child: Text(
                    StringUtils.shorten(dto.lastVoiceMessageSenderName, 8),
                    style: TextStyle(
                      fontSize: 12.w,
                      color: DesignColor.info,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8.w,),
                Text(
                  "的語音留言",
                  style: TextStyle(
                      fontSize: 12.w
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.network(
                        dto.storyImageUrl,
                      )
                    )
                  )
                ),
                SizedBox(width: 8.w,),
                SizedBox(
                  height: 60.w,
                  width: 236.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        dto.storyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ConfigColor.textColorDefault,
                          fontSize: 12.w
                        )
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildChannelImage(dto.channelImageUrl, dto.channelName),
                          SizedBox(width: 2.w,),
                          Marquee(
                            animationDuration: const Duration(seconds: 10),
                            directionMarguee: DirectionMarguee.oneDirection,
                            child: Text(
                              dto.channelName,
                              style: TextStyle(
                                color: ConfigColor.textColorDefault,
                                fontSize: 12.w
                              )
                            )
                          )
                        ],
                      ),
                      const Spacer(),
                    ],
                  )
                )
              ],
            )
          ],
        ),
      )
    );
  }

  Widget gotNewMessage(BuildContext context, VoiceMessageNoticeDto dto) {
    return GestureDetector(
      onTap: () {
        String collaboratorIdParam = dto.collaboratorId == ""? "null" : dto.collaboratorId;
        router.push("/voiceMessage/story/${dto.storyId}/owner/${dto.storyOwnerId}/collaborator/$collaboratorIdParam");
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: DesignSystem.shadow
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "收到了一則語音留言",
                  style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.timeAgo(dto.updateTime),
                  style: TextStyle(
                    fontSize: 12.w
                  ),
                )
              ]
            ),
            SizedBox(height: 4.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "來自",
                  style: TextStyle(
                    fontSize: 12.w,
                  ),
                ),
                SizedBox(width: 8.w,),
                Avatar(dto.lastThreeResponseUserList![0].userId, dto.lastThreeResponseUserList![0].userAvatarImageUrl, 18.w),
                SizedBox(width: 4.w,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return OtherUserInfoScreen(dto.lastThreeResponseUserList![0].userId);
                    }));
                  },
                  child: Text(
                    StringUtils.shorten(dto.lastThreeResponseUserList![0].username, 8),
                    style: TextStyle(
                      fontSize: 12.w,
                      color: DesignColor.info,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8.w,),
                Text(
                  "的語音留言",
                  style: TextStyle(
                    fontSize: 12.w
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h,),
            Row(
              children: [
                SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Image.network(
                          dto.storyImageUrl,
                        )
                    )
                  )
                ),
                SizedBox(width: 8.w,),
                SizedBox(
                  width: 220.w,
                  height: 60.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        dto.storyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ConfigColor.textColorDefault,
                          fontSize: 12.w
                        )
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          buildChannelImage(dto.channelImageUrl, dto.channelName),
                          SizedBox(width: 2.w,),
                          Expanded(
                            child: Marquee(
                              animationDuration: const Duration(seconds: 10),
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                dto.channelName,
                                style: TextStyle(
                                  color: ConfigColor.textColorDefault,
                                  fontSize: 12.w
                                )
                              )
                            )
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  )
                )
              ],
            ),
          ],
        )
      )
    );
  }

  Widget gotDonation(BuildContext context, VoiceMessageNoticeDto dto) {
    return GestureDetector(
        onTap: () {
          String collaboratorIdParam = dto.collaboratorId == ""? "null" : dto.collaboratorId;
          router.push("/voiceMessage/story/${dto.storyId}/owner/${dto.storyOwnerId}/collaborator/$collaboratorIdParam");
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w),
            boxShadow: DesignSystem.shadow
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "你收到了 ${StringUtils.shorten(dto.lastThreeResponseUserList![0].username, 10)} 的贊助",
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimeUtils.timeAgo(dto.updateTime),
                    style: TextStyle(
                      fontSize: 12.w
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.h,),
              Row(
                children: [
                  Text(
                    "Podcoin: ",
                    style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color: DesignColor.secondary500
                    ),
                    child: Row(
                      children: [
                        PodCoin(size: 12.w),
                        SizedBox(width: 2,),
                        Text(
                          dto.donateAmount.toString(),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
              SizedBox(height: 5.h,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Image.network(
                          dto.storyImageUrl,
                        )
                      )
                    )
                  ),
                  SizedBox(width: 8.w,),
                  SizedBox(
                    height: 60.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          dto.storyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ConfigColor.textColorDefault,
                            fontSize: 12.w
                          )
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildChannelImage(dto.channelImageUrl, dto.channelName),
                            SizedBox(width: 2.w,),
                            Marquee(
                                animationDuration: const Duration(seconds: 10),
                                directionMarguee: DirectionMarguee.oneDirection,
                                child: Text(
                                  dto.channelName,
                                  style: TextStyle(
                                    color: ConfigColor.textColorDefault,
                                    fontSize: 12.w
                                  )
                                )
                            )
                          ],
                        ),
                        const Spacer(),
                      ],
                    )
                  )
                ],
              )
            ],
          ),
        )
    );
  }

  Widget buildChannelImage(String imageUrl, String channelName) {
    if(imageUrl == "") {
      return Container(
        color: Colors.grey,
        width: 16.w,
        height: 16.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.w),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Center(
              child: Text(
                channelName[0]
              ),
            )
          )
        )
      );
    }

    return SizedBox(
      width: 16.w,
      height: 16.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.network(
              imageUrl,
            )
        )
      )
    );
  }
}