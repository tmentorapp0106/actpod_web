import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
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
    _playerController = PlayerController();
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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
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
                            ListenToMessage(_playerController!),
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
          ],
        ),
      ),
    );
  }
}