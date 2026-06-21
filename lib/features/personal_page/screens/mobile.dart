import 'package:actpod_web/features/personal_page/components/mobile/story_channel_tab_view.dart';
import 'package:actpod_web/features/personal_page/components/mobile/user_info.dart';
import 'package:actpod_web/features/personal_page/components/mobile/web_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobilePersonalScreen extends StatelessWidget {
  final TabController tabController;

  const MobilePersonalScreen({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Column(
            children: [
              WebLogo(),
              UserInfoWidget(),
              StoryChannelTabView(tabController),
            ],
          ),
        ),
      ),
    );
  }
}
