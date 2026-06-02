import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/record_feature/components/rss_sync_screen/channel_drop_down.dart';
import 'package:quick_share_app/features/record_feature/components/rss_sync_screen/space_drop_down.dart';
import 'package:quick_share_app/features/record_feature/controllers/list_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../../../services/toast_service.dart';
import '../components/rss_sync_screen/episode_list.dart';
import '../controllers/feed_controller.dart';
import '../providers/providers.dart';


class RssSyncScreen extends ConsumerStatefulWidget{
  final String feed;

  RssSyncScreen({required this.feed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return RssSyncScreenState();
  }
}

class RssSyncScreenState extends ConsumerState<RssSyncScreen> {
  FeedController? feedController;
  ListController? listController;

  @override
  void initState() {
    super.initState();
    feedController = FeedController(ref);
    listController = ListController(ref: ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      listController!.getChannels();
      listController!.getSpaces();
      try {
        feedController!.fetchPodcastRss(widget.feed);
      } catch (e) {
        ref.watch(rssFeedProvider.notifier).state = [];
        ToastService.showNoticeToast("找不到內容");
      }
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void initProviders() {
    ref.watch(spaceSelectionProvider.notifier).state = null;
    ref.watch(channelSelectionProvider.notifier).state = null;
    ref.watch(spaceListProvider.notifier).state = [];
    ref.watch(channelListProvider.notifier).state = [];
    ref.watch(rssFeedProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text("綁定 RSS Feed"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                SpaceDropDown(),
                const SizedBox(height: 12,),
                ChannelDropDown(),
                RssFeedListView(
                  feed: widget.feed,
                  feedController: feedController!,
                )
              ],
            )
          )
        )
      )
    );
  }
}