import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_feature/components/other_user_info/stories_view.dart';
import 'package:quick_share_app/features/user_info_feature/components/other_user_info/channels_view.dart';

import '../../../../design_system/color.dart';
import '../../../../design_system/design.dart';

class StoryChannelTabView extends ConsumerWidget {
  final TabController _controller;

  StoryChannelTabView(this._controller);

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
                indicatorColor: ConfigColor.textColorDefault,
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
            StoriesView(),
            ChannelsView(),
          ],
        )
      ),
    );
  }
}