import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/mini_player.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_feature/components/other_user_info/share_button.dart';
import 'package:quick_share_app/features/user_info_feature/components/other_user_info/user_info.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/other_user_info_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/story_controller.dart';
import 'package:quick_share_app/providers.dart';
import '../components/other_user_info/back_button.dart';
import '../components/other_user_info/story_channel_tab_view.dart';
import '../controllers/channel_controller.dart';
import '../providers.dart';

class OtherUserInfoScreen extends ConsumerStatefulWidget {
  final String otherUserId;

  OtherUserInfoScreen(this.otherUserId);

  @override
  ConsumerState<OtherUserInfoScreen> createState() {
    return OtherUserInfoScreenState();
  }
}

class OtherUserInfoScreenState extends ConsumerState<OtherUserInfoScreen> with TickerProviderStateMixin {
  OtherUserInfoController? _otherUserInfoController;
  StoryController? _storyAndCollectionController;
  ChannelController? _channelController;
  TabController? _controller;

  OtherUserInfoScreenState();

  @override
  void initState() {
    super.initState();
    _otherUserInfoController = OtherUserInfoController(ref);
    _storyAndCollectionController = StoryController(ref);
    _channelController = ChannelController(ref);
    _controller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      ref.watch(otherUserInfoProvider.notifier).state = null;
      ref.watch(otherStoryListProvider.notifier).state = null;
      ref.watch(otherChannelListProvider.notifier).state = null;
      ref.watch(otherStoryCountProvider.notifier).state = 0;
      ref.watch(loadingProvider.notifier).state = true;
      ref.watch(syncProcessingProvider.notifier).state = false;
      try {
        await Future.wait([
          _otherUserInfoController!.getOtherUserInfo(widget.otherUserId),
          _storyAndCollectionController!.getOtherUserStories(widget.otherUserId),
          _storyAndCollectionController!.getOtherStoryCount(widget.otherUserId),
          _channelController!.getOthersChannels(widget.otherUserId),
        ]);
      } catch(e) {
        print(e);
        ref.watch(loadingProvider.notifier).state = false;
      }
      ref.watch(loadingProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (canPop, object) {
      },
      child: WholePageLoading(
        provider: loadingProvider,
        child: Scaffold(
          backgroundColor: ConfigColor.background,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    children:[
                      UserInfoWidget(),
                      StoryChannelTabView(_controller!),
                    ]
                  )
                ),
                Positioned(
                  top: 4.w,
                  left: 12.w,
                  child: UserInfoBackButton()
                ),
                Positioned(
                  top: 4.w,
                  right: 12.w,
                  child: PersonalInfoShareButton()
                ),
                MiniPlayer(
                  bottomPadding: 40.h
                )
              ]
            )
          )
        )
      )
    );
  }
}