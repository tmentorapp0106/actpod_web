import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/back_button.dart';
import 'package:quick_share_app/components/mini_player.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/components/channel_image.dart';
import 'package:quick_share_app/features/channel_page_feature/components/channel_stat.dart';
import 'package:quick_share_app/features/channel_page_feature/components/edit_button.dart';
import 'package:quick_share_app/features/channel_page_feature/components/podcast_store_button.dart';
import 'package:quick_share_app/features/channel_page_feature/components/story_list.dart';
import 'package:quick_share_app/features/channel_page_feature/components/title.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/podcast_store_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../design_system/design.dart';
import '../components/channel_desc.dart';
import '../components/collect_button.dart';
import '../components/user_info.dart';
import '../controllers/collection_controller.dart';

class ChannelScreen extends ConsumerStatefulWidget {
  final String channelId;

  ChannelScreen(this.channelId);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChannelScreenState();
  }
}

class ChannelScreenState extends ConsumerState<ChannelScreen> {
  ChannelController? channelController;
  CollectionController? collectionController;
  PodcastStoreController? podcastStoreController;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    channelController = ChannelController(ref, nameController, descriptionController);
    collectionController = CollectionController(ref);
    podcastStoreController = PodcastStoreController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      collectionController!.checkCollected(widget.channelId);
      channelController!.getChannelStories(widget.channelId);
      await channelController!.getChannelInfo(widget.channelId);
      podcastStoreController!.getPodcastStore(ref.read(channelInfoProvider)!.userId);
      previewPlayerController.reset(ref, PreviewPage.channel);
    });
  }

  void initProviders() {
    ref.watch(channelStoriesProvider.notifier).state = [];
    ref.watch(channelInfoProvider.notifier).state = null;
    ref.watch(channelStoryPreviewIndexProvider.notifier).state = null;
    ref.watch(channelStoryPreviewPlayStatusProvider.notifier).state = "paused";
    ref.watch(editChannelImageUrlProvider.notifier).state = "";
    ref.watch(channelCoOwnersProvider.notifier).state = [];
  }

  @override
  void dispose() {
    previewPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 36.h,
        surfaceTintColor: Colors.white,
        title: AnimatedOpacity(
          opacity: ref.watch(isChannelCardVisibleProvider)? 0.0 : 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: Row(
            children: [
              ChannelImage(
                size: 24.w,
                borderRadius: 4.w,
              ),
              SizedBox(width: 4.w,),
              Column(
                children: [
                  SizedBox(
                    width: 200.w,
                    child: Text(
                      ref.watch(channelInfoProvider)?.channelName?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                  const SizedBox(height: 4,)
                ],
              )
            ],
          ),
        ),
        centerTitle: false,
        leading: ActPodBackButton(),  // Back button
        backgroundColor: Colors.white
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 上面那張卡片 + 標題「故事」
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VisibilityDetector(
                      key: const Key('channel-info-card'),
                      onVisibilityChanged: (info) {
                        final visible = info.visibleFraction > 0.2;
                        final isVisible = ref.watch(isChannelCardVisibleProvider);
                        if (visible != isVisible) {
                          ref.watch(isChannelCardVisibleProvider.notifier).state = visible;
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 4.h, right: 12.w, left: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xfffefefe),
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(color: DesignSystem.borderGrey),
                          boxShadow: DesignSystem.shadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ChannelImage(
                                  size: 120.w,
                                  borderRadius: 16.w,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 120.w,
                                  width: 200.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Spacer(),
                                      ChannelTitle(),
                                      const Spacer(),
                                      UserInfo(),
                                      const Spacer(),
                                      const SizedBox(height: 4),
                                      ChannelState(),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ChannelDesc(),
                            const SizedBox(height: 16),
                            if(!UserService.hasLoggedIn())
                              Row(
                                children: [
                                  CollectButton(
                                    channelId: widget.channelId,
                                    collectionController: collectionController!,
                                  ),
                                ],
                              ),
                            if(UserService.hasLoggedIn())
                              Row(
                                children: [
                                  ref.read(channelInfoProvider)?.userId == UserService.getUserInfo()?.userId?
                                    EditButton(
                                      channelController: channelController!,
                                      nameController: nameController,
                                      descriptionController: descriptionController,
                                    ) :
                                    CollectButton(
                                      channelId: widget.channelId,
                                      collectionController: collectionController!,
                                    ),
                                  Visibility(
                                    visible: ref.watch(podcastStoreProvider) != null,
                                    child: SizedBox(width: 8,)
                                  ),
                                  PodcastStoreButton()
                                ],
                              ),
                            if(!UserService.hasLoggedIn())
                              Row(
                                children: [
                                  PodcastStoreButton()
                                ],
                              ),
                          ],
                        ),
                      )
                    ),
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        "故事",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                  ],
                ),
              ),
              // 故事清單：要用 sliver，才能跟整頁一起捲
              StoryList(), // 👈 改成 sliver 版本（下面給你）
            ]
          ),
          MiniPlayer(
            bottomPadding: 40.h,
          )
        ]
      ),
    );
  }
}
