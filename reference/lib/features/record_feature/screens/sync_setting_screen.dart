import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/record_feature/components/sync_setting_screen/channel_drop_down.dart';
import 'package:quick_share_app/features/record_feature/components/sync_setting_screen/remove_button.dart';
import 'package:quick_share_app/features/record_feature/components/sync_setting_screen/space_drop_down.dart';
import 'package:quick_share_app/features/record_feature/components/sync_setting_screen/update_button.dart';
import 'package:quick_share_app/features/record_feature/controllers/list_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../components/sync_setting_screen/feed.dart';
import '../components/sync_setting_screen/instant_sync_button.dart';
import '../controllers/feed_controller.dart';
import '../providers/providers.dart';


class SyncSettingScreen extends ConsumerStatefulWidget{

  SyncSettingScreen();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SyncSettingScreenState();
  }
}

class SyncSettingScreenState extends ConsumerState<SyncSettingScreen> {
  FeedController? feedController;
  ListController? listController;

  @override
  void initState() {
    super.initState();
    feedController = FeedController(ref);
    listController = ListController(ref: ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      feedController!.getSyncSetting();
      listController!.getChannels();
      listController!.getSpaces();
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void initProviders() {
    ref.watch(syncSettingProvider.notifier).state = null;
    ref.watch(spaceSelectionProvider.notifier).state = null;
    ref.watch(channelSelectionProvider.notifier).state = null;
    ref.watch(spaceListProvider.notifier).state = [];
    ref.watch(channelListProvider.notifier).state = [];
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
            title: const Text("RSS Feed 綁定設定"),
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
                    const SizedBox(height: 12,),
                    Feed(),
                    const SizedBox(height: 32,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UpdateButton(feedController: feedController!,),
                        const SizedBox(width: 40,),
                        InstantSyncButton(feedController: feedController!)
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RemoveButton(feedController: feedController!)
                      ],
                    ),
                    SizedBox(height: 40.h,)
                  ],
                )
            )
        )
      )
    );
  }
}