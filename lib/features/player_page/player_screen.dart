import 'dart:async';
import 'dart:io';

import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/player_page/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_comment.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_content_switch.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comments.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_interactive_content.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_login_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_box.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_talk_to_creator.dart';
import 'package:actpod_web/features/player_page/components/web/web_about_story.dart';
import 'package:actpod_web/features/player_page/components/web/web_download_box.dart';
import 'package:actpod_web/features/player_page/components/web/web_likes_button.dart';
import 'package:actpod_web/features/player_page/components/web/web_listen_count.dart';
import 'package:actpod_web/features/player_page/components/web/web_logo.dart';
import 'package:actpod_web/features/player_page/components/web/web_player_box.dart';
import 'package:actpod_web/features/player_page/components/web/web_send_message_button.dart';
import 'package:actpod_web/features/player_page/components/web/web_story_image.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/controllers/stat_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/color.dart';
import 'components/mobile/mobile_about_story.dart';
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
  CommentController? _commentController;
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _instantCommentFocusNode = FocusNode();
  Timer? _instantCommentTimer;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController(ref);
    _statController = StatController(ref);
    _commentController = CommentController(ref: ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initProviders();
      _playerController!.getStoryInfo(widget.storyId);
      _statController!.getLikesCount(widget.storyId);
      checkOpenDeepLink();
      initInstantComment();
    });
  }

  void initInstantComment() async {
    _commentController!.clearInstantQueue();
    await _commentController!.getInstantComments(widget.storyId);
    _instantCommentTimer?.cancel();
    _instantCommentTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _commentController!.fireInstantComment(context);
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
        await Future.delayed(const Duration(microseconds: 500));
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
    ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
    ref.watch(playContentProvider.notifier).state = PlayContent.story;
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(storyStateProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);
    Widget body;
    if(storyInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if(storyInfo.storyId.isEmpty) {
      body = Center(
        child: Text(
          "找不到故事",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w,
            fontWeight: FontWeight.bold
          ),
        ),
      );
    } else {
      body = isPhone? mobileScreen() : Center(
        child: Text("此頁面僅支援手機瀏覽器觀看"),
      );
    }
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: SafeArea(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          child: body
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
              Stack(
                children: [
                  WebLogo(),
                ],
              ),
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
                    Expanded(child: WebStoryInfoBar()),
                    SizedBox(height: 2.h,),
                    WebStoryImage(),
                    SizedBox(height: 2.h,),
                    WebAboutStory(),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: 120.w, 
                      child: Divider(thickness: 0.4.w),
                    ),
                    SizedBox(
                      width: 120.w, 
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WebLikesButton(),
                          SizedBox(width: 2.w),
                          WebSendMessageButton(),
                          const Spacer(),
                          WebListenCount()
                        ],
                      )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h,),
              WebDownloadBox(),
              SizedBox(height: 160.h,)
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
                Stack(
                  children: [
                    Positioned(
                      right: 12.w,
                      bottom: 0,
                      child: MobileLoginButton(_playerController!),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/actpod_logo_web.png",
                        width: 72.w,
                        fit: BoxFit.fitWidth,
                      )
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 0.h, bottom: 8.h, left: 8.w, right: 8.w),
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MobileStoryInfoBar(),
                      SizedBox(height: 16.h),
                      Stack(
                        children: [
                          MobileStoryImage(),
                          MobileInteractiveContent(playerController: _playerController!),
                          MobileContentSwitch(playerController: _playerController!),
                          MobileInstantComments()
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MobileTalkToCreator(storyId: widget.storyId),
                          SizedBox(width: 12.w,),
                          InstantCommentButton(
                            focusNode: _instantCommentFocusNode,
                            commentController: _commentController!,
                            storyId: widget.storyId,
                            playerController: _playerController!,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      MobileAboutStory(),
                      SizedBox(height: 5.h),
                      MobileComment(
                        commentController: _commentController!,
                        focusNode: _commentFocusNode,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100.h,)
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