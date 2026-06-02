import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/components/story_bottom_sheet.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/story_api_dto/get_channel_stories_res.dart';
import '../../../components/story_card.dart';
import '../../../design_system/color.dart';
import '../../../design_system/components/podcoin.dart';
import '../../../dto/player_item_dto.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../router.dart';
import '../../../utils/time_utils.dart';

class StoryList extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyList = ref.watch(channelStoriesProvider);
    final channelInfo = ref.watch(channelInfoProvider);
    bool showMoreIcon = false;
    if(UserService.hasLoggedIn() && channelInfo != null &&
        (UserService.getUserInfo()!.userId == channelInfo.userId || channelInfo.coOwners.contains(UserService.getUserInfo()!.userId))
    ) {
      showMoreIcon = true;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: StoryCard(
              index,
              moreIconFunction: showMoreIcon? () {
                showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.w)
                        )
                    ),
                    builder: (context) {
                      return StoryBottomSheet(storyList[index]);
                    }
                );
              } : null,
              getChannelStoriesResItem: storyList[index],
              previewPlayFunction: previewPlayerController.previewPlayFunction
            )
          );
        },
        childCount: storyList.length,
      ),
    );
  }
}