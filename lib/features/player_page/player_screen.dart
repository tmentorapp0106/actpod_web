import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/player_page/components/player_box.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../design_system/color.dart';
import 'components/about_story.dart';
import 'components/likes_button.dart';
import 'components/listen_to_message.dart';
import 'components/send_message_button.dart';
import 'components/story_image.dart';
import 'components/story_info_bar.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  PlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initProviders();
      _playerController!.getStoryInfo("67e412e34275cb000145e96d");
    });
  }

  void initProviders() {
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(likesCountProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColor.background,
      appBar: AppBar(
        toolbarHeight: 30.h,
        centerTitle: true,
        backgroundColor: DesignColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 60.h), // Add bottom padding for the player
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.only(top: 20.h, bottom: 10.h, left: 20.w, right: 20.w),
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: DesignShadow.shadow,
                          borderRadius: BorderRadius.circular(15.w),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StoryInfoBar(),
                            SizedBox(height: 10.h),
                            StoryImage(),
                            SizedBox(height: 5.h),
                            AboutStory(),
                            SizedBox(height: 5.h),
                            Divider(thickness: 1.5.w),
                            Row(
                              children: [
                                LikesButton(),
                                SizedBox(width: 5.w),
                                SendMessageButton(_playerController!),
                                const Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10.h,
                child: PlayerBox(_playerController!),
              ),
            ],
          ),
        )
      ),
    );
  }
}