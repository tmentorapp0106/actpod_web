import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/user_info_feature/components/stories_view.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/story_controller.dart';

import '../../../design_system/color.dart';
import '../controllers/download_controller.dart';
import 'channels_view.dart';

class StoryChannelTabView extends ConsumerWidget {
  final TabController _controller;
  final bool _viewingOthers;
  final StoryController _storyController;
  final DownloadController _downloadController;
  final ChannelController _channelController;

  StoryChannelTabView(
      this._controller,
      this._viewingOthers,
      this._storyController,
      this._downloadController,
      this._channelController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Scaffold(
        backgroundColor: ConfigColor.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: ConfigColor.background,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                overlayColor: WidgetStateProperty.all(DesignColor.actpodPrimary400.withOpacity(0.12)),
                indicator: UnderlineTabIndicator(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: DesignSystem.primary,
                    width: 4
                  ),
                  insets: EdgeInsets.symmetric(horizontal:15.0)
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _controller,
                tabs: [
                  Tab(
                    child: Text(
                      "故事",
                      style: TextStyle(
                        fontSize: 16.w,
                        color: ConfigColor.textColorDefault
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "頻道",
                      style: TextStyle(
                        fontSize: 16.w,
                        color: ConfigColor.textColorDefault
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          controller: _controller,
          children: [
            StoriesView(_viewingOthers, _storyController, _downloadController),
            ChannelsView(_channelController),
          ],
        )
      ),
    );
  }
}