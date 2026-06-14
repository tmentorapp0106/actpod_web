import 'dart:async';

import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/channel_image.dart';
import 'package:actpod_web/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobiel_collect_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_comment.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_comment_list_model.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_content_switch.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_list_model.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comments.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_interactive_content.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_login_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_box.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_talk_to_creator.dart';
import 'package:actpod_web/features/player_page/components/unlock_dialog.dart';
import 'package:actpod_web/features/player_page/controllers/collection_controller.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/controllers/stat_controller.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/color.dart';
import '../../utils/time_utils.dart';
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
      _collectionController!
          .checkCollected(ref.read(storyInfoProvider)?.channelId ?? "");
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
    ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
    ref.watch(playContentProvider.notifier).state = PlayContent.story;
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(storyStateProvider.notifier).state = null;
    ref.watch(isCollectedProvider.notifier).state = null;
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 116),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _WebHeader(playerController: _playerController!),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final sideColumn = Column(
                          children: [
                            _WebAboutCard(),
                            const SizedBox(height: 16),
                            _WebCommentCard(
                              commentController: _commentController!,
                              focusNode: _commentFocusNode,
                            ),
                            const SizedBox(height: 16),
                            const _WebDownloadCard(),
                          ],
                        );

                        final storyCard = _WebStoryCard(
                          collectionController: _collectionController!,
                          playerController: _playerController!,
                          commentController: _commentController!,
                          commentFocusNode: _commentFocusNode,
                          instantCommentFocusNode: _instantCommentFocusNode,
                          storyId: widget.storyId,
                        );

                        if (constraints.maxWidth < 960) {
                          return Column(
                            children: [
                              storyCard,
                              const SizedBox(height: 18),
                              sideColumn,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: storyCard),
                            const SizedBox(width: 24),
                            Expanded(flex: 4, child: sideColumn),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _WebPlayerDock(playerController: _playerController!)),
      ],
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

class _WebHeader extends StatelessWidget {
  final PlayerController playerController;

  const _WebHeader({required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            height: 30,
            fit: BoxFit.fitHeight,
          ),
          const Spacer(),
          _WebAccountButton(playerController: playerController),
        ],
      ),
    );
  }
}

class _WebStoryCard extends ConsumerWidget {
  final CollectionController collectionController;
  final PlayerController playerController;
  final CommentController commentController;
  final FocusNode commentFocusNode;
  final FocusNode instantCommentFocusNode;
  final String storyId;

  const _WebStoryCard({
    required this.collectionController,
    required this.playerController,
    required this.commentController,
    required this.commentFocusNode,
    required this.instantCommentFocusNode,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    if (storyInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignShadow.shadow,
      ),
      child: Column(
        children: [
          _WebStoryInfo(
            storyInfo: storyInfo,
            collectionController: collectionController,
          ),
          const SizedBox(height: 16),
          _WebMediaPanel(playerController: playerController),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _WebActionButton(
                icon: Icons.mic_none_rounded,
                text: "跟創作者對話",
                onPressed: () => _openStoryDeepLink(context, storyId),
              ),
              _WebActionButton(
                icon: Icons.bubble_chart_rounded,
                text: "傳送即時留言",
                onPressed: () async {
                  commentController.getInstantComments(storyId);
                  await InstantCommentBottomModel(
                    focusNode: instantCommentFocusNode,
                    commentController: commentController,
                    storyId: storyId,
                    playerController: playerController,
                  ).show(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebAccountButton extends ConsumerWidget {
  final PlayerController playerController;

  const _WebAccountButton({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(null, userInfo.avatarUrl, 28),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              userInfo.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DesignColor.neutral90,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return const LoginScreen();
          },
        );
        final storyInfo = ref.read(storyInfoProvider);
        if (storyInfo?.isPremium ?? false) {
          playerController.checkPaid(storyInfo!.storyId);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: DesignColor.primary50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Text(
        "登入",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _WebActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _WebActionButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignColor.primary500,
          side: const BorderSide(color: DesignColor.primary500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Future<void> _openStoryDeepLink(BuildContext context, String storyId) async {
  final bool? goto = await showDialog<bool>(
    context: context,
    builder: (context) => LaunchDeepLinkDialog(),
  );

  if (goto != true) {
    return;
  }

  await Future.delayed(const Duration(microseconds: 500));
  await _launchStoryExternal(storyId);
}

Future<void> _launchStoryExternal(String storyId) async {
  final url =
      "https://actpod-488af.web.app/story/link/$storyId?openExternalBrowser=1";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $url");
  }
}

class _WebDownloadCard extends StatelessWidget {
  const _WebDownloadCard();

  @override
  Widget build(BuildContext context) {
    return const _WebSideCard(
      child: Column(
        children: [
          Text(
            "下載 APP 收聽更多內容",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 12,
            children: [
              _WebStoreButton(
                imagePath: "assets/images/apple_download.png",
                url: "https://apps.apple.com/tw/app/actpod/id6468426325",
              ),
              _WebStoreButton(
                imagePath: "assets/images/google_download.png",
                url:
                    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebStoreButton extends StatelessWidget {
  final String imagePath;
  final String url;

  const _WebStoreButton({
    required this.imagePath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          imagePath,
          width: 128,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class _WebPlayerDock extends ConsumerWidget {
  final PlayerController playerController;

  const _WebPlayerDock({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioLength = ref.watch(audioLengthProvider);
    final seekPosition = ref.watch(audioPositionProvider);
    final playerState = ref.watch(playerStatusProvider);
    final likeCount = ref.watch(storyStateProvider)?.likeCount.toString() ?? "";

    final totalMs = audioLength.inMilliseconds;
    final positionMs = seekPosition.inMilliseconds.clamp(0, totalMs);
    final sliderMax = totalMs <= 0 ? 1.0 : totalMs.toDouble();
    final sliderValue = totalMs <= 0 ? 0.0 : positionMs.toDouble();

    return Center(
      child: Container(
        width: 620,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: DesignShadow.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: DesignColor.primary50,
                inactiveTrackColor: const Color(0xFFD6D6D6),
                thumbColor: DesignColor.primary50,
                overlayColor: DesignColor.primary50.withValues(alpha: 0.16),
              ),
              child: Slider(
                min: 0,
                max: sliderMax,
                value: sliderValue,
                onChanged: totalMs <= 0
                    ? null
                    : (value) {
                        playerController.seekPosition(
                          Duration(milliseconds: value.round()),
                        );
                      },
              ),
            ),
            Row(
              children: [
                Text(
                  TimeUtils.formatDuration(seekPosition, "HH:mm:ss"),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatDuration(audioLength, "HH:mm:ss"),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WebSpeedDropdown(playerController: playerController),
                _WebIconButton(
                  icon: Image.asset(
                    "assets/icons/backward_15.png",
                    width: 30,
                    height: 30,
                  ),
                  onTap: () {
                    playerController.backward(const Duration(seconds: 15));
                  },
                ),
                _WebPlayControl(
                  playerController: playerController,
                  playerState: playerState,
                ),
                _WebIconButton(
                  icon: Image.asset(
                    "assets/icons/forward_15.png",
                    width: 30,
                    height: 30,
                  ),
                  onTap: () {
                    playerController.forward(const Duration(seconds: 15));
                  },
                ),
                SizedBox(
                  width: 72,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      final storyId = ref.read(storyStateProvider)?.storyId;
                      if (storyId != null) {
                        _openStoryDeepLink(context, storyId);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: DesignColor.primary50,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likeCount,
                            style: const TextStyle(
                              color: DesignColor.neutral70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSpeedDropdown extends ConsumerWidget {
  final PlayerController playerController;

  const _WebSpeedDropdown({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 72,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ref.watch(playerSpeedTextProvider),
          isDense: true,
          alignment: Alignment.center,
          items: const ["1.0X", "0.5X", "1.5X"]
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  alignment: Alignment.center,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(playerSpeedTextProvider.notifier).state = value;
            if (value == "1.5X") {
              playerController.setSpeed(1.5);
            } else if (value == "0.5X") {
              playerController.setSpeed(0.5);
            } else {
              playerController.setSpeed(1.0);
            }
          },
        ),
      ),
    );
  }
}

class _WebIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _WebIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 44,
        child: Center(child: icon),
      ),
    );
  }
}

class _WebPlayControl extends ConsumerWidget {
  final PlayerController playerController;
  final PlayerStatus playerState;

  const _WebPlayControl({
    required this.playerController,
    required this.playerState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerState == PlayerStatus.unpaid) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () async {
          final bool? goto = await showDialog<bool>(
            context: context,
            builder: (context) => UnlockDialog(),
          );
          if (goto == true) {
            await Future.delayed(const Duration(microseconds: 500));
            final storyId = ref.read(storyStateProvider)?.storyId;
            if (storyId != null && context.mounted) {
              _launchStoryExternal(storyId);
            }
          }
        },
        child: Image.asset(
          "assets/images/podcoins.png",
          width: 46,
          height: 46,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        if (playerState == PlayerStatus.preparing) {
          return;
        }
        if (playerState == PlayerStatus.playing) {
          playerController.pause();
        } else {
          playerController.play();
        }
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: playerState == PlayerStatus.preparing
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: DesignColor.primary50,
                    strokeWidth: 2.4,
                  ),
                )
              : Icon(
                  playerState == PlayerStatus.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 52,
                  color: DesignColor.primary50,
                ),
        ),
      ),
    );
  }
}

class _WebStoryInfo extends StatelessWidget {
  final GetOneStoryResItem storyInfo;
  final CollectionController collectionController;

  const _WebStoryInfo({
    required this.storyInfo,
    required this.collectionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          storyInfo.storyName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            ChannelImage(
              storyInfo.channelImageUrl,
              storyInfo.channelName,
              48,
              22,
              radius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storyInfo.channelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _WebUserChip(
                        userId: storyInfo.userId,
                        avatarUrl: storyInfo.avatarUrl,
                        name: storyInfo.nickname,
                      ),
                      if (storyInfo.collaboratorId.isNotEmpty)
                        _WebUserChip(
                          userId: storyInfo.collaboratorId,
                          avatarUrl: storyInfo.collaboratorAvatarUrl,
                          name: storyInfo.collaboratorName,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            CollectButton(collectionController: collectionController),
          ],
        ),
      ],
    );
  }
}

class _WebUserChip extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String name;

  const _WebUserChip({
    required this.userId,
    required this.avatarUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Avatar(userId, avatarUrl, 20),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WebMediaPanel extends ConsumerWidget {
  final PlayerController playerController;

  const _WebMediaPanel({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playContent = ref.watch(playContentProvider);
    final storyInfo = ref.watch(storyInfoProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: playContent == PlayContent.story
                      ? _WebStoryImage(storyInfo: storyInfo)
                      : _WebInteractiveContent(
                          playerController: playerController,
                        ),
                ),
              ),
              _WebContentSwitch(playerController: playerController),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebStoryImage extends StatelessWidget {
  final GetOneStoryResItem? storyInfo;

  const _WebStoryImage({required this.storyInfo});

  @override
  Widget build(BuildContext context) {
    final imageUrl = storyInfo?.storyImageUrl ?? "";
    if (imageUrl.isEmpty) {
      return Container(
        color: DesignColor.neutral50,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
    );
  }
}

class _WebInteractiveContent extends ConsumerWidget {
  final PlayerController playerController;

  const _WebInteractiveContent({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactiveList = ref.watch(interactiveMessageInfoListProvider);
    final interactiveIndex =
        ref.watch(interactiveMessageInfoIndexProvider) ?? 0;

    if (interactiveList == null) {
      return const Center(
        child: CircularProgressIndicator(color: DesignColor.primary50),
      );
    }

    if (interactiveList.isEmpty) {
      return Container(
        color: DesignColor.neutral50,
        child: const Center(
          child: Text(
            "尚無語音留言",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final activeIndex = interactiveIndex.clamp(0, interactiveList.length - 1);

    return Container(
      color: DesignColor.neutral50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DesignColor.primary50, width: 5),
            ),
            child: Center(
              child: Avatar(
                null,
                interactiveList[activeIndex].avatarUrl,
                164,
              ),
            ),
          ),
          const SizedBox(width: 34),
          SizedBox(
            width: 54,
            height: 260,
            child: ListView.separated(
              itemCount: interactiveList.length,
              itemBuilder: (context, index) {
                final selected = activeIndex == index;
                return GestureDetector(
                  onTap: () {
                    playerController.seekPosition(
                      Duration(
                          milliseconds: interactiveList[index].fromMilliSec),
                    );
                  },
                  child: Container(
                    width: selected ? 52 : 46,
                    height: selected ? 52 : 46,
                    padding: EdgeInsets.all(selected ? 3 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: DesignColor.primary50, width: 3)
                          : null,
                    ),
                    child: Avatar(
                      null,
                      interactiveList[index].avatarUrl,
                      selected ? 46 : 42,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebContentSwitch extends ConsumerWidget {
  final PlayerController playerController;

  const _WebContentSwitch({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playContent = ref.watch(playContentProvider);
    final hasInteractiveContent =
        ref.watch(interactiveMessageInfoListProvider)?.isNotEmpty ?? false;

    if (!hasInteractiveContent) {
      return const SizedBox.shrink();
    }

    final isStory = playContent == PlayContent.story;

    return Positioned(
      bottom: 14,
      right: isStory ? 14 : null,
      left: isStory ? null : 14,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          playerController.playIndex(isStory ? 1 : 0);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isStory)
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              Text(
                isStory ? "語音留言" : "收聽正片",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isStory)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebAboutCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    return _WebSideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "關於這則故事",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Text(
                TimeUtils.convertToFormat(
                  "yyyy/MM/dd",
                  storyInfo?.storyUploadTime ?? DateTime.now(),
                ),
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if ((storyInfo?.spaceName ?? "").isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DesignColor.neutral100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                storyInfo!.spaceName,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Linkify(
            onOpen: (link) async {
              await launchUrl(
                Uri.parse(link.url),
                mode: LaunchMode.inAppBrowserView,
              );
            },
            options: const LinkifyOptions(humanize: false),
            text: storyInfo?.storyDescription ?? "",
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF303030),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _WebStatItem(
                icon: Icons.favorite_border_outlined,
                label:
                    ref.watch(storyStateProvider)?.likeCount.toString() ?? "0",
              ),
              const SizedBox(width: 16),
              _WebStatItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: ref.watch(storyStateProvider)?.commentCount.toString() ??
                    "0",
              ),
              const Spacer(),
              Text(
                "收聽次數：${storyInfo?.count ?? 0}",
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebStatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WebStatItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF777777)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _WebCommentCard extends ConsumerWidget {
  final CommentController commentController;
  final FocusNode focusNode;

  const _WebCommentCard({
    required this.commentController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyStat = ref.watch(storyStateProvider);
    final showedComment = storyStat?.showedComment;

    return _WebSideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "文字留言",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: storyStat == null
                ? null
                : () {
                    commentController.getComments(storyStat.storyId);
                    CommentBottomModel(
                      commentController: commentController,
                      focusNode: focusNode,
                    ).show(
                      context,
                      storyStat.storyId,
                      UserPrefs.getUserInfo()?.userId,
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DesignColor.neutral50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: storyStat == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DesignColor.primary50,
                      ),
                    )
                  : showedComment == null
                      ? const Text(
                          "尚無文字留言",
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(
                              showedComment.userId,
                              showedComment.avatarUrl,
                              36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    showedComment.nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    showedComment.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSideCard extends StatelessWidget {
  final Widget child;

  const _WebSideCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignShadow.shadow,
      ),
      child: child,
    );
  }
}
