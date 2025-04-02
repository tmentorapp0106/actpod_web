import 'dart:io';

import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/player_page/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_download_box.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_listen_count.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_box.dart';
import 'package:actpod_web/features/player_page/components/web/web_about_story.dart';
import 'package:actpod_web/features/player_page/components/web/web_download_box.dart';
import 'package:actpod_web/features/player_page/components/web/web_likes_button.dart';
import 'package:actpod_web/features/player_page/components/web/web_logo.dart';
import 'package:actpod_web/features/player_page/components/web/web_player_box.dart';
import 'package:actpod_web/features/player_page/components/web/web_send_message_button.dart';
import 'package:actpod_web/features/player_page/components/web/web_story_image.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/controllers/stat_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

import '../../design_system/color.dart';
import 'components/mobile/mobile_about_story.dart';
import 'components/mobile/mobile_likes_button.dart';
import 'components/mobile/mobile_listen_to_message.dart';
import 'components/mobile/mobile_send_message_button.dart';
import 'components/mobile/mobile_story_image.dart';
import 'components/mobile/mobile_story_info_bar.dart';
import 'components/web/web_story_info_bar.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String storyId;

  const PlayerScreen(this.storyId);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  PlayerController? _playerController;
  StatController? _statController;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController(ref);
    _statController = StatController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initProviders();
      _playerController!.getStoryInfo(widget.storyId);
      _statController!.getLikesCount(widget.storyId);
      // "67e412e34275cb000145e96d"
      checkOpenDeepLink();
    });
  }

  Future<void> checkOpenDeepLink() async {
    String url;
    if(kIsWeb) {
      bool? goto = await showDialog<bool>(
        context: context,
        builder: (context) => LaunchDeepLinkDialog(),
      );
      if(goto != null && goto) {
        url = "https://actpod-488af.web.app/story/link/${widget.storyId}?openExternalBrowser=1";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      }
    }
  }

  void initProviders() {
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(likesCountProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: SafeArea(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          child: isPhone? mobileScreen() : webScreen()
        )
      ),
    );
  }

  Widget webScreen() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WebLogo(),
              SizedBox(height: 4.h,),
              Container(
                width: 140.w,
                padding: EdgeInsets.only(top: 2.h, bottom: 2.h, left: 8.w, right: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: DesignShadow.shadow,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WebStoryInfoBar(),
                    SizedBox(height: 2.h,),
                    WebStoryImage(),
                    SizedBox(height: 2.h,),
                    WebAboutStory(),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: 104.w, 
                      child: Divider(thickness: 0.4.w),
                    ),
                    SizedBox(
                      width: 104.w, 
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WebLikesButton(),
                          SizedBox(width: 2.w),
                          WebSendMessageButton(),
                        ],
                      )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h,),
              WebDownloadBox(),
            ],
          ),
        ),
        Positioned(
          bottom: 10.h,
          left: 0,
          right: 0,
          child: WebPlayerBox(_playerController!)
        ),
      ],
    );
  }

  Widget mobileScreen() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 60.h, top: 8.h), // Add bottom padding for the player
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/actpod_logo_web.png",
                  width: 120.w,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 8.h,),
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
                      MobileStoryInfoBar(),
                      SizedBox(height: 10.h),
                      MobileStoryImage(),
                      SizedBox(height: 5.h),
                      MobileAboutStory(),
                      SizedBox(height: 5.h),
                      Divider(thickness: 1.5.w),
                      Row(
                        children: [
                          MobileLikesButton(),
                          SizedBox(width: 5.w),
                          MobileSendMessageButton.MobileSendMessageButton(_playerController!),
                          const Spacer(),
                          MobileListenCount()
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h,),
                MobileDownloadBox()
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10.h,
          child: MobilePlayerBox(_playerController!),
        ),
      ],
    );
  }
}