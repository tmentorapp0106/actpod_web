import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/channel_image.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/collect_button.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/collection_controller.dart';

import '../../../components/avatar.dart';
import '../../../router.dart';
import '../../../utils/string_utils.dart';

class UserInfoBarWidget extends ConsumerWidget {
  final PlayerItemDto storyInfo;
  final CollectionController collectionController;

  UserInfoBarWidget({required this.storyInfo, required this.collectionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              router.push("/channel/${storyInfo.channelId}");
            },
            child: ChannelImage(storyInfo.channelImageUrl, storyInfo.channelName, 52.w, 52.w),
          ),
          SizedBox(width: 8.w,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storyInfo.channelName,
                  style: TextStyle(
                    fontSize: 16.w,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Avatar(storyInfo.userId, storyInfo.userAvatar, 16.w),
                    SizedBox(width: 4.w,),
                    Text(
                      StringUtils.shorten(storyInfo.userName, 12),
                      style: TextStyle(
                          fontSize: 12.w
                      ),
                    ),
                    SizedBox(width: 8.w,),
                    Visibility(
                        visible: storyInfo.collaboratorId != "",
                        child: Row(
                          children: [
                            Avatar(storyInfo.collaboratorId, storyInfo.collaboratorAvatarUrl, 16.w),
                            SizedBox(width: 4.w,),
                            Text(
                              StringUtils.shorten(storyInfo.collaboratorName, 12),
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
          ),
          SizedBox(width: 4.w),
          CollectButton(collectionController: collectionController, storyInfo: storyInfo,)
        ],
      )
    );
  }
}