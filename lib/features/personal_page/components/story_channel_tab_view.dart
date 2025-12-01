import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/personal_page/components/channels_view.dart';
import 'package:actpod_web/features/personal_page/components/stories_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoryChannelTabView extends ConsumerWidget {
  final TabController _controller;

  StoryChannelTabView(this._controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Scaffold(
        backgroundColor: DesignColor.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: DesignColor.background,
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: DesignColor.primary50,
              width: 4
            ),
            insets: EdgeInsets.symmetric(horizontal:15.0)
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
          controller: _controller,
          tabs: [
            Tab(
              child: Text(
                "故事",
                style: TextStyle(
                  fontSize: 16.w,
                  color: Colors.black
                ),
              ),
            ),
            Tab(
              child: Text(
                "頻道",
                style: TextStyle(
                  fontSize: 16.w,
                  color: Colors.black
                ),
              ),
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