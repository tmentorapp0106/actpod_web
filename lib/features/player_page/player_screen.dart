import 'dart:async';

import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_comment.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_content_switch.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comments.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_interactive_content.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_login_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_box.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_talk_to_creator.dart';
import 'package:actpod_web/features/player_page/components/web/player_web_screen.dart';
import 'package:actpod_web/features/player_page/controllers/collection_controller.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/controllers/stat_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/color.dart';
import 'components/mobile/mobile_about_story.dart';
import 'components/mobile/mobile_story_image.dart';
import 'components/mobile/mobile_story_info_bar.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String storyId;

  const PlayerScreen(this.storyId, {super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  PlayerController? _playerController;
  StatController? _statController;
  CommentController? _commentController;
  CollectionController? _collectionController;
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _instantCommentFocusNode = FocusNode();
  Timer? _instantCommentTimer;
  bool _adultContentDialogShown = false;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController(ref);
    _statController = StatController(ref);
    _commentController = CommentController(ref: ref);
    _collectionController = CollectionController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      checkOpenDeepLink();
      initInstantComment();
      _statController!.getLikesCount(widget.storyId);
      await _playerController!.getStoryInfo(widget.storyId);
      await confirmAdultContentIfNeeded();
      if (!mounted) return;
      _collectionController!
          .checkCollected(ref.read(storyInfoProvider)?.channelId ?? "");
    });
  }

  @override
  void dispose() {
    unawaited(_playerController?.dispose());
    _instantCommentTimer?.cancel();
    _commentFocusNode.dispose();
    _instantCommentFocusNode.dispose();
    super.dispose();
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
    if (kIsWeb && MediaQuery.of(context).size.width < 600) {
      bool? goto = await showDialog<bool>(
        context: context,
        builder: (context) => LaunchDeepLinkDialog(),
      );
      if (goto != null && goto) {
        await Future.delayed(const Duration(microseconds: 500));
        url =
            "https://actpod-488af.web.app/story/link/${widget.storyId}?openExternalBrowser=1";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      }
    }
  }

  void initProviders() {
    final currentStoryInfo = ref.read(storyInfoProvider);
    final isSameStory = currentStoryInfo?.storyId == widget.storyId;

    ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
    ref.watch(playContentProvider.notifier).state = PlayContent.story;
    if (isSameStory) {
      return;
    }

    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(storyStateProvider.notifier).state = null;
    ref.watch(isCollectedProvider.notifier).state = null;
    ref.watch(audioLengthProvider.notifier).state = Duration.zero;
    ref.watch(audioPositionProvider.notifier).state = Duration.zero;
    ref.watch(playerStatusProvider.notifier).state = PlayerStatus.preparing;
    ref.watch(interactiveMessageInfoListProvider.notifier).state = null;
    ref.watch(interactiveMessageInfoIndexProvider.notifier).state = null;
    ref.watch(interactiveContentUrlProvider.notifier).state = null;
  }

  Future<void> confirmAdultContentIfNeeded() async {
    final storyInfo = ref.read(storyInfoProvider);
    if (_adultContentDialogShown ||
        storyInfo?.contentRating.toLowerCase() != "adult") {
      return;
    }

    _adultContentDialogShown = true;
    final isAdult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: const Text(
            "內容含有敏感話題，是否滿 18 歲",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("未滿 18 歲"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("已滿 18 歲"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (isAdult != true) {
      if (myRouter.canPop()) {
        myRouter.pop();
      } else {
        myRouter.go("/explore");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);
    Widget body;
    if (storyInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (storyInfo.storyId.isEmpty) {
      body = Center(
        child: Text(
          "找不到故事",
          style: TextStyle(
              color: Colors.black, fontSize: 16.w, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      body = isPhone ? mobileScreen() : webScreen();
    }
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: SafeArea(
          child: SizedBox(height: ScreenUtil().screenHeight, child: body)),
    );
  }

  Widget webScreen() {
    return PlayerWebScreen(
      playerController: _playerController!,
      collectionController: _collectionController!,
      commentController: _commentController!,
      commentFocusNode: _commentFocusNode,
      instantCommentFocusNode: _instantCommentFocusNode,
      storyId: widget.storyId,
    );
  }

  Widget mobileScreen() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: 60.h, top: 8.h), // Add bottom padding for the player
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
                        )),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: 0.h, bottom: 8.h, left: 8.w, right: 8.w),
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MobileStoryInfoBar(_collectionController!),
                      SizedBox(height: 16.h),
                      Stack(
                        children: [
                          MobileStoryImage(),
                          MobileInteractiveContent(
                              playerController: _playerController!),
                          MobileContentSwitch(
                              playerController: _playerController!),
                          MobileInstantComments()
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MobileTalkToCreator(storyId: widget.storyId),
                          SizedBox(
                            width: 12.w,
                          ),
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
                SizedBox(
                  height: 100.h,
                )
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
