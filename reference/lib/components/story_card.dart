import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_channel_stories_res.dart';
import 'package:quick_share_app/components/channel_image.dart';
import 'package:quick_share_app/components/image_carousal.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/shared_prefs/hide_prefs.dart';
import 'package:quick_share_app/utils/link_utils.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:readmore/readmore.dart';

import '../config/color.dart';
import '../controllers/preview_controller.dart';
import '../dto/player_item_dto.dart';
import '../dto/space_story_dto.dart';
import '../dto/story_recommendation_dto.dart';
import '../features/edit_and_upload_story_feature/dto/upload_preview_dto.dart';
import '../features/space_story_feature/providers.dart';
import '../main.dart';
import '../services/player_service.dart';
import '../utils/time_utils.dart';
import 'avatar.dart';

class StoryCard extends ConsumerWidget {
  final int index;
  VoidCallback? moreIconFunction;
  Function? previewPlayFunction;
  RecommendationItem? recommendationItem;
  SpaceStoryDto? spaceStoryDto;
  GetChannelStoriesResItem? getChannelStoriesResItem;
  UploadPreviewDto? uploadPreviewDto;

  StoryCard(this.index, {this.recommendationItem, this.spaceStoryDto, this.uploadPreviewDto, this.previewPlayFunction, this.getChannelStoriesResItem, this.moreIconFunction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if(recommendationItem != null) {
      return fromRecommendation(recommendationItem!, context, ref);
    } else if(spaceStoryDto != null) {
      return fromSpaceStory(spaceStoryDto!, context, ref);
    } else if(getChannelStoriesResItem != null) {
      return fromGetChannelStoriesResItem(getChannelStoriesResItem!, context, ref);
    } else {
      return fromUploadPreview(uploadPreviewDto!, context, ref);
    }
  }

  Widget fromUploadPreview(UploadPreviewDto uploadPreviewDto, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                },
                child: ChannelImage(uploadPreviewDto.channelImageUrl, uploadPreviewDto.channelName, 52.w, 52.w),
              ),
              SizedBox(width: 8.w,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uploadPreviewDto.channelName,
                    style: TextStyle(
                      fontSize: 20.w,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Avatar(UserService.getUserInfo()!.userId, UserService.getUserInfo()!.avatarUrl, 16.w),
                      SizedBox(width: 4.w,),
                      Text(
                        StringUtils.shorten(UserService.getUserInfo()!.nickname, 12),
                        style: TextStyle(
                            fontSize: 12.w
                        ),
                      ),
                      SizedBox(width: 8.w,),
                      Visibility(
                          visible: uploadPreviewDto.collaboratorId != "",
                          child: Row(
                            children: [
                              Avatar(uploadPreviewDto.collaboratorId, uploadPreviewDto.collaboratorAvatarUrl, 16.w),
                              SizedBox(width: 4.w,),
                              Text(
                                StringUtils.shorten(uploadPreviewDto.collaboratorName, 12),
                                style: TextStyle(
                                    fontSize: 12.w
                                ),
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 4.h,)
                ],
              )
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 340.w,
                      height: 340.w,
                      child: FileImageCarousel(imageFiles: uploadPreviewDto.storyImages),
                    ),
                  ],
                )
              ]
          ),
          SizedBox(height: 4.h,),
          Row(
            children: [
              Expanded(
                  child: Text(
                    uploadPreviewDto.storyName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ConfigColor.textColorDefault,
                      fontSize: 18.w, // Fixed font size
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: ReadMoreText(
                    uploadPreviewDto.storyDescription,
                    textAlign: TextAlign.start,
                    trimMode: TrimMode.Line,
                    trimLines: 2,
                    trimCollapsedText: '展開更多',
                    trimExpandedText: '\n隱藏顯示',
                    moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                    lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                    annotations: [
                      // URL
                      Annotation(
                        regExp: RegExp(
                          r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                        ),
                        spanBuilder: ({
                          required String text,
                          TextStyle? textStyle,
                        }) {
                          return TextSpan(
                            text: text,
                            style: (textStyle ?? const TextStyle()).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blueAccent,
                              color: Colors.blueAccent,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                          );
                        },
                      )
                    ],
                  )
              ),
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.w),
                          color: Colors.black26.withOpacity(0.05)
                      ),
                      padding: EdgeInsets.only(left: 10.w, top: 2.h, right: 10.w, bottom: 4.h), // for Mandarin
                      child: Text(
                        uploadPreviewDto.spaceName,
                        textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                        style: TextStyle(
                          fontSize: 12.w,
                        ),
                      )
                  ),
                  SizedBox(height: 4.h,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TimeUtils.convertToFormat("yyyy-MM-dd", DateTime.now()),
                        style: TextStyle(
                            fontSize: 14.w,
                            color: DesignColor.neutral400
                        ),
                      ),
                      SizedBox(width: 12.w,),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: DesignColor.neutral70,
                        size: 14.w,
                      ),
                      SizedBox(width: 2.w,),
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: DesignColor.neutral70
                        ),
                      ),
                      SizedBox(width: 12.w,),
                      Icon(
                        Icons.bubble_chart_outlined,
                        color: DesignColor.neutral70,
                        size: 14.w,
                      ),
                      SizedBox(width: 2.w,),
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: DesignColor.neutral70
                        ),
                      ),
                      SizedBox(width: 12.w,),
                      SvgPicture.asset(
                          "assets/icons/home_page/favorite.svg",
                          width: 14.w,
                          height: 14.w,
                          fit: BoxFit.fitWidth,
                          color: DesignColor.neutral70
                      ),
                      SizedBox(width: 2.w,),
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: DesignColor.neutral70
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  playOrPay(isPremium: uploadPreviewDto.isPremium),
                  Text(
                    TimeUtils.formatDuration(uploadPreviewDto.storyLength, "HH:mm:ss"),
                    style: TextStyle(
                        color: DesignColor.neutral70,
                        fontSize: 12.w
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget fromSpaceStory(SpaceStoryDto spaceStoryDto, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  router.push("/channel/${spaceStoryDto.channelId}");
                },
                child: ChannelImage(spaceStoryDto.channelImageUrl, spaceStoryDto.channelName, 52.w, 52.w),
              ),
              SizedBox(width: 8.w,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spaceStoryDto.channelName,
                    style: TextStyle(
                      fontSize: 20.w,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Avatar(spaceStoryDto.userId, spaceStoryDto.userAvatarUrl, 16.w),
                      SizedBox(width: 4.w,),
                      Text(
                        StringUtils.shorten(spaceStoryDto.username, 12),
                        style: TextStyle(
                            fontSize: 12.w
                        ),
                      ),
                      SizedBox(width: 8.w,),
                      Visibility(
                          visible: spaceStoryDto.collaboratorId != "",
                          child: Row(
                            children: [
                              Avatar(spaceStoryDto.collaboratorId, spaceStoryDto.collaboratorAvatarUrl, 16.w),
                              SizedBox(width: 4.w,),
                              Text(
                                StringUtils.shorten(spaceStoryDto.collaboratorName, 12),
                                style: TextStyle(
                                    fontSize: 12.w
                                ),
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 4.h,)
                ],
              )
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _openPlayerPage(PlayerItemDto.fromSpaceStoryDto(spaceStoryDto), ref);
                      },
                      child: SizedBox(
                        width: 340.w,
                        height: 340.w,
                        child: NetworkImageCarousel(imageUrls: spaceStoryDto.storyImageUrls),
                      )
                    ),

                    Positioned(
                      left: 4.w,
                      bottom: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          previewPlayFunction!(ref, index, spaceStoryDto.previewUrl, PreviewPage.space);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xff222222).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              previewIcon(ref),
                              SizedBox(width: 4.w),
                              Text(
                                "試聽精華",
                                style: TextStyle(color: Colors.white, fontSize: 12.w),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ]
          ),
          SizedBox(height: 4.h,),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _openPlayerPage(PlayerItemDto.fromSpaceStoryDto(spaceStoryDto), ref);
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                          spaceStoryDto.storyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ConfigColor.textColorDefault,
                            fontSize: 18.w, // Fixed font size
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: ReadMoreText(
                          spaceStoryDto.storyDescription,
                          textAlign: TextAlign.start,
                          trimMode: TrimMode.Line,
                          trimLines: 2,
                          trimCollapsedText: '展開更多',
                          trimExpandedText: '\n隱藏顯示',
                          moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                          lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                          annotations: [
                            // URL
                            Annotation(
                              regExp: RegExp(
                                r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                              ),
                              spanBuilder: ({
                                required String text,
                                TextStyle? textStyle,
                              }) {
                                return TextSpan(
                                  text: text,
                                  style: (textStyle ?? const TextStyle()).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blueAccent,
                                    color: Colors.blueAccent,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                                );
                              },
                            )
                          ],
                        )
                    ),
                  ],
                ),
                SizedBox(height: 8.h,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                color: Colors.black26.withOpacity(0.05)
                            ),
                            padding: EdgeInsets.only(left: 10.w, top: 2.h, right: 10.w, bottom: 4.h), // for Mandarin
                            child: Text(
                              spaceStoryDto.spaceName,
                              textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                              style: TextStyle(
                                fontSize: 12.w,
                              ),
                            )
                        ),
                        SizedBox(height: 4.h,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              TimeUtils.convertToFormat("yyyy-MM-dd", spaceStoryDto.releaseTime),
                              style: TextStyle(
                                  fontSize: 14.w,
                                  color: DesignColor.neutral400
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: DesignColor.neutral70,
                              size: 14.w,
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${spaceStoryDto.commentCount}",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignColor.neutral70
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            Icon(
                              Icons.bubble_chart_outlined,
                              color: DesignColor.neutral70,
                              size: 14.w,
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${spaceStoryDto.instantCommentCount}",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignColor.neutral70
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            SvgPicture.asset(
                                "assets/icons/home_page/favorite.svg",
                                width: 14.w,
                                height: 14.w,
                                fit: BoxFit.fitWidth,
                                color: DesignColor.neutral70
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${spaceStoryDto.likesCount}",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignColor.neutral70
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        playOrPay(isPremium: spaceStoryDto.isPremium, playerItem: PlayerItemDto.fromSpaceStoryDto(spaceStoryDto), ref: ref),
                        Text(
                          TimeUtils.formatDuration(Duration(milliseconds: spaceStoryDto.totalLength), "HH:mm:ss"),
                          style: TextStyle(
                              color: DesignColor.neutral70,
                              fontSize: 12.w
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget fromRecommendation(RecommendationItem recommendationItem, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  router.push("/channel/${recommendationItem.channelId}");
                },
                child: ChannelImage(recommendationItem.channelImageUrl, recommendationItem.channelName, 52.w, 52.w),
              ),
              SizedBox(width: 8.w,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendationItem.channelName,
                    style: TextStyle(
                      fontSize: 20.w,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Avatar(recommendationItem.userId, recommendationItem.userAvatarUrl, 16.w),
                      SizedBox(width: 4.w,),
                      Text(
                        StringUtils.shorten(recommendationItem.username, 12),
                        style: TextStyle(
                          fontSize: 12.w
                        ),
                      ),
                      SizedBox(width: 8.w,),
                      Visibility(
                        visible: recommendationItem.collaboratorId != "",
                        child: Row(
                          children: [
                            Avatar(recommendationItem.collaboratorId, recommendationItem.collaboratorAvatarUrl, 16.w),
                            SizedBox(width: 4.w,),
                            Text(
                              StringUtils.shorten(recommendationItem.collaboratorName, 12),
                              style: TextStyle(
                                fontSize: 12.w
                              ),
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 4.h,)
                ],
              )
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _openPlayerPage(PlayerItemDto.fromRecommendationItem(recommendationItem), ref);
                    },
                    child: SizedBox(
                      width: 340.w,
                      height: 340.w,
                      child: NetworkImageCarousel(imageUrls: recommendationItem.storyImageUrls),
                    )
                  ),
                  Positioned(
                    left: 4.w,
                    bottom: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        previewPlayFunction!(ref, index, recommendationItem.previewUrl, PreviewPage.home);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xff222222).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            previewIcon(ref),
                            SizedBox(width: 4.w),
                            Text(
                              "試聽精華",
                              style: TextStyle(color: Colors.white, fontSize: 12.w),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ]
          ),
          SizedBox(height: 4.h,),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _openPlayerPage(PlayerItemDto.fromRecommendationItem(recommendationItem), ref);
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommendationItem.storyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ConfigColor.textColorDefault,
                          fontSize: 18.w, // Fixed font size
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ReadMoreText(
                        recommendationItem.storyDescription,
                        textAlign: TextAlign.start,
                        trimMode: TrimMode.Line,
                        trimLines: 2,
                        trimCollapsedText: '展開更多',
                        trimExpandedText: '\n隱藏顯示',
                        moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                        lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                        annotations: [
                          // URL
                          Annotation(
                            regExp: RegExp(
                              r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                            ),
                            spanBuilder: ({
                              required String text,
                              TextStyle? textStyle,
                            }) {
                              return TextSpan(
                                text: text,
                                style: (textStyle ?? const TextStyle()).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blueAccent,
                                  color: Colors.blueAccent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                              );
                            },
                          )
                        ],
                      )
                    ),
                  ],
                ),
                SizedBox(height: 8.h,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              color: Colors.black26.withOpacity(0.05)
                          ),
                          padding: EdgeInsets.only(left: 10.w, top: 2.h, right: 10.w, bottom: 4.h), // for Mandarin
                          child: Text(
                            recommendationItem.spaceName,
                            textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                            style: TextStyle(
                              fontSize: 12.w,
                            ),
                          )
                        ),
                        SizedBox(height: 4.h,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              TimeUtils.convertToFormat("yyyy-MM-dd", recommendationItem.releaseTime),
                              style: TextStyle(
                                  fontSize: 14.w,
                                  color: DesignColor.neutral400
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: DesignColor.neutral70,
                              size: 14.w,
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${recommendationItem.commentCount}",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: DesignColor.neutral70
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            Icon(
                              Icons.bubble_chart_outlined,
                              color: DesignColor.neutral70,
                              size: 14.w,
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${recommendationItem.instantCommentCount}",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignColor.neutral70
                              ),
                            ),
                            SizedBox(width: 12.w,),
                            SvgPicture.asset(
                                "assets/icons/home_page/favorite.svg",
                                width: 14.w,
                                height: 14.w,
                                fit: BoxFit.fitWidth,
                                color: DesignColor.neutral70
                            ),
                            SizedBox(width: 2.w,),
                            Text(
                              "${recommendationItem.likesCount}",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignColor.neutral70
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        playOrPay(isPremium: recommendationItem.isPremium, playerItem: PlayerItemDto.fromRecommendationItem(recommendationItem), ref: ref),
                        Text(
                          TimeUtils.formatDuration(Duration(milliseconds: recommendationItem.totalLength), "HH:mm:ss"),
                          style: TextStyle(
                              color: DesignColor.neutral70,
                              fontSize: 12.w
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ]
      )
    );
  }

  Widget fromGetChannelStoriesResItem(GetChannelStoriesResItem getChannelStoriesResItem, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              ChannelImage(
                getChannelStoriesResItem.channelImageUrl,
                getChannelStoriesResItem.channelName,
                52.w,
                52.w,
              ),
              SizedBox(width: 8.w),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getChannelStoriesResItem.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.w,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Avatar(
                          getChannelStoriesResItem.userId,
                          getChannelStoriesResItem.userAvatarUrl,
                          16.w,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            StringUtils.shorten(getChannelStoriesResItem.username, 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Visibility(
                          visible: getChannelStoriesResItem.collaboratorId != "",
                          child: Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Avatar(
                                  getChannelStoriesResItem.collaboratorId,
                                  getChannelStoriesResItem.collaboratorAvatarUrl,
                                  16.w,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    StringUtils.shorten(
                                      getChannelStoriesResItem.collaboratorName,
                                      12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),

              Visibility(
                visible: moreIconFunction != null,
                child: IconButton(
                  onPressed: moreIconFunction,
                  icon: Icon(
                    Icons.more_vert,
                    size: 24.w,
                    color: Colors.black,
                  ),
                )
              ),
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _openPlayerPage(PlayerItemDto.fromGetChannelStoriesResItem(getChannelStoriesResItem), ref);
                      },
                      child: SizedBox(
                        width: 344.w,
                        height: 344.w,
                        child: NetworkImageCarousel(imageUrls: getChannelStoriesResItem.storyImageUrls),
                      )
                    ),

                    Positioned(
                      left: 4.w,
                      bottom: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          previewPlayFunction!(ref, index, getChannelStoriesResItem.previewUrl, PreviewPage.channel);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xff222222).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              previewIcon(ref),
                              SizedBox(width: 4.w),
                              Text(
                                "試聽精華",
                                style: TextStyle(color: Colors.white, fontSize: 12.w),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ]
          ),
          SizedBox(height: 4.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _openPlayerPage(PlayerItemDto.fromGetChannelStoriesResItem(getChannelStoriesResItem), ref);
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                            getChannelStoriesResItem.storyName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ConfigColor.textColorDefault,
                              fontSize: 18.w, // Fixed font size
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ReadMoreText(
                            getChannelStoriesResItem.storyDescription,
                            textAlign: TextAlign.start,
                            trimMode: TrimMode.Line,
                            trimLines: 2,
                            trimCollapsedText: '展開更多',
                            trimExpandedText: '\n隱藏顯示',
                            moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                            lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                            annotations: [
                              // URL
                              Annotation(
                                regExp: RegExp(
                                  r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                                ),
                                spanBuilder: ({
                                  required String text,
                                  TextStyle? textStyle,
                                }) {
                                  return TextSpan(
                                    text: text,
                                    style: (textStyle ?? const TextStyle()).copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blueAccent,
                                      color: Colors.blueAccent,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                                  );
                                },
                              )
                            ],
                          )
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.w),
                                  color: Colors.black26.withOpacity(0.05)
                              ),
                              padding: EdgeInsets.only(left: 10.w, top: 2.h, right: 10.w, bottom: 4.h), // for Mandarin
                              child: Text(
                                getChannelStoriesResItem.spaceName,
                                textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                                style: TextStyle(
                                  fontSize: 12.w,
                                ),
                              )
                          ),
                          SizedBox(height: 4.h,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                TimeUtils.convertToFormat("yyyy-MM-dd", getChannelStoriesResItem.releaseTime),
                                style: TextStyle(
                                    fontSize: 14.w,
                                    color: DesignColor.neutral400
                                ),
                              ),
                              SizedBox(width: 12.w,),
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: DesignColor.neutral70,
                                size: 14.w,
                              ),
                              SizedBox(width: 2.w,),
                              Text(
                                "${getChannelStoriesResItem.commentCount}",
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DesignColor.neutral70
                                ),
                              ),
                              SizedBox(width: 12.w,),
                              Icon(
                                Icons.bubble_chart_outlined,
                                color: DesignColor.neutral70,
                                size: 14.w,
                              ),
                              SizedBox(width: 2.w,),
                              Text(
                                "${getChannelStoriesResItem.instantCommentCount}",
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DesignColor.neutral70
                                ),
                              ),
                              SizedBox(width: 12.w,),
                              SvgPicture.asset(
                                "assets/icons/home_page/favorite.svg",
                                width: 14.w,
                                height: 14.w,
                                fit: BoxFit.fitWidth,
                                color: DesignColor.neutral70
                              ),
                              SizedBox(width: 2.w,),
                              Text(
                                "${getChannelStoriesResItem.likesCount}",
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DesignColor.neutral70
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          playOrPay(isPremium: getChannelStoriesResItem.isPremium, playerItem: PlayerItemDto.fromGetChannelStoriesResItem(getChannelStoriesResItem), ref: ref),
                          Text(
                            TimeUtils.formatDuration(Duration(milliseconds: getChannelStoriesResItem.totalLength), "HH:mm:ss"),
                            style: TextStyle(
                                color: DesignColor.neutral70,
                                fontSize: 12.w
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  Widget commentAndThumbsUpCount(int commentCount, int thumbsUpCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
            Icons.thumb_up_outlined,
            color: Colors.white,
            size: 20.w
        ),
        SizedBox(width: 5.w,),
        Text(
          thumbsUpCount.toString(),
          style: TextStyle(
              fontSize: 14.sp,
              color: ConfigColor.textColorSecondary
          ),
        ),
        SizedBox(width: 10.w,),
        SvgPicture.asset(
          "assets/icons/comment.svg",
          width: 20.w,
          height: 20.w,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(width: 5.w,),
        Text(
          commentCount.toString(),
          style: TextStyle(
              fontSize: 14.sp,
              color: ConfigColor.textColorSecondary
          ),
        ),
      ],
    );
  }

  Widget previewIcon(WidgetRef ref) {
    if(ref.watch(previewPlayIndexProvider) == index) {
      if(ref.watch(previewPlayStatusProvider) == PreviewPlayStatus.loading) {
        return Container(
          margin: EdgeInsets.only(right: 4.w),
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.w,
          ),
        );
      } else {
        return Icon(
          Icons.pause_rounded,
          color: Colors.white,
          size: 20.w,
        );
      }
    } else {
      return Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 20.w,
      );
    }
  }

  Widget playOrPay({required bool isPremium, PlayerItemDto? playerItem, WidgetRef? ref}) {
    if(isPremium) {
      return GestureDetector(
        onTap: () {
          _openPlayerPage(playerItem, ref);
        },
        child: Container(
          padding: EdgeInsets.only(left: 4.w, right: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: DesignColor.primary50, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
                child: PodCoin(size: 20.w),
              ),
              Text(
                "付費收聽",
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF9E1B), // orange text
                ),
              ),
            ],
          ),
        )
      );
    }

    return GestureDetector(
      onTap: () async {
        if(playerItem == null || ref == null) {
          return;
        }
        if(ref.watch(mainPlayerStoryInfoProvider) != null &&
            ref.watch(mainPlayerStoryInfoProvider)?.storyId == playerItem.storyId &&
            ref.watch(mainPlayerStatusProvider) == MainPlayerState.playing) {
          actPodAudioHandler?.pause();
        } else if(ref.watch(mainPlayerStoryInfoProvider) != null &&
            ref.watch(mainPlayerStoryInfoProvider)?.storyId == playerItem.storyId &&
            ref.watch(mainPlayerStatusProvider) == MainPlayerState.paused) {
          actPodAudioHandler?.play();
        } else if(ref.watch(mainPlayerStoryInfoProvider) != null &&
            ref.watch(mainPlayerStoryInfoProvider)?.storyId == playerItem.storyId &&
            ref.watch(mainPlayerStatusProvider) == MainPlayerState.loading || ref.watch(mainPlayerStatusProvider) == MainPlayerState.initiating) {
          return;
        } else {
          await actPodAudioHandler?.stop();
          ref.watch(mainPlayerStoryInfoProvider.notifier).state = playerItem;
          ref.watch(mainPlayerItemListProvider.notifier).state = [playerItem];
          ref.watch(loadingPlayerStoryInfoProvider.notifier).state = playerItem;
          playerService.changeMusicByUrl(
            id: playerItem.storyId,
            title: playerItem.storyName,
            url: playerItem.storyUrl,
            album: playerItem.channelName,
            artist: playerItem.storyDescription,
            artUrl: playerItem.storyImageUrls[0],
            repeatMode: AudioServiceRepeatMode.none,
            showSeekControls: true,
            captureVoiceMessages: true,
            storyOwnerId: playerItem.userId,
            voiceMessageStatus: playerItem.voiceMessageStatus
          );
          // await playerService.setAudio([playerItem], 0,
          //   () async {
          //     actPodAudioHandler?.play();
          //   },
          //       (isPlaying){},
          //       (position){},
          //       (bufferPosition) {},
          //       (storyId){},
          //       (){},
          // );
          ref.watch(loadingPlayerStoryInfoProvider.notifier).state = null;
        }
      },
      child: Container(
        width: 36.w, // Adjust the size as needed
        height: 36.w, // Make it a circle
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular shape
          color: ConfigColor.primaryDefault,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFe5a000).withOpacity(0.20), // Shadow color
              blurRadius: 16.67, // Softness of the shadow
              offset: Offset(0, 1.3), // Position of the shadow
            ),
          ],
        ),
        child: Center(
          child: ref?.watch(mainPlayerStoryInfoProvider) != null &&
            ref?.watch(mainPlayerStoryInfoProvider)?.storyId == playerItem?.storyId &&
            (ref?.watch(mainPlayerStatusProvider) == MainPlayerState.loading || ref?.watch(mainPlayerStatusProvider) == MainPlayerState.initiating)? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
          ) : Icon(
              ref?.watch(mainPlayerStoryInfoProvider) != null &&
              ref?.watch(mainPlayerStoryInfoProvider)?.storyId == playerItem?.storyId &&
              ref?.watch(mainPlayerStatusProvider) == MainPlayerState.playing?
            Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28.w,
          ),
        ),
      )
    );
  }

  Future<void> _openPlayerPage(PlayerItemDto? playerItem, WidgetRef? ref) async {
    if(playerItem == null || ref == null) {
      return;
    }
    previewPlayerController.stop(ref, force: true);
    List<PlayerItemDto> playList = [playerItem];
    await router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});

    List<RecommendationItem> recommendList = ref.read(recommendationListProvider);
    recommendList.removeWhere((recommendation) {
      return HidePrefs.contain(recommendation.storyId);
    });
    ref.watch(recommendationListProvider.notifier).state = [...recommendList];
  }
}