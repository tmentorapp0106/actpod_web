import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/instant_comment_switch.dart';
import 'package:quick_share_app/features/play_record_feature/components/player_box.dart';
import 'package:quick_share_app/features/play_record_feature/components/report_and_hidden_button.dart';
import 'package:quick_share_app/features/play_record_feature/components/send_message_button.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/collection_controller.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/likes_controller.dart';

import '../../../components/centered_marquee.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../router.dart';
import '../../../services/user_service.dart';
import '../components/about_story.dart';
import '../components/comment_section.dart';
import '../components/image_instant_comment.dart';
import '../components/instant_comment_button.dart';
import '../components/share_button.dart';
import '../components/user_info_bar.dart';
import '../controllers/player_controller.dart';
import '../controllers/comment_controller.dart';
import '../providers.dart';

class PlayRecordScreen extends ConsumerStatefulWidget {
  final List<PlayerItemDto> playerItemDtoList;
  final int initialIndex;
  final bool isNewPlayerItem;

  PlayRecordScreen(
      this.playerItemDtoList, this.initialIndex, this.isNewPlayerItem);

  @override
  ConsumerState<PlayRecordScreen> createState() {
    return PlayRecordScreenState();
  }
}

class PlayRecordScreenState extends ConsumerState<PlayRecordScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _instantCommentFocusNode = FocusNode();
  late final Widget _titleWidget;
  PlayerController? playerController;
  CommentController? commentController;
  LikesController? thumbsController;
  CollectionController? collectionController;
  Timer? _instantCommentTimer;

  PlayRecordScreenState();

  void _handleCommentFocusChange() {
    ref.watch(inputFocusProvider.notifier).state = _commentFocusNode.hasFocus;
  }

  void _handleInstantCommentFocusChange() {
    ref.watch(instantInputFocusProvider.notifier).state =
        _instantCommentFocusNode.hasFocus;
  }

  @override
  void initState() {
    super.initState();
    collectionController = CollectionController(ref);
    commentController =
        CommentController(ref, widget.playerItemDtoList[widget.initialIndex]);
    thumbsController =
        LikesController(ref, widget.playerItemDtoList[widget.initialIndex]);
    playerController = PlayerController(
        ref,
        commentController!,
        thumbsController!,
        context,
        widget.playerItemDtoList[widget.initialIndex]);
    _commentFocusNode.addListener(_handleCommentFocusChange);
    _instantCommentFocusNode.addListener(_handleInstantCommentFocusChange);
    WidgetsBinding.instance.addObserver(this);

    // 為了避免因為 instant comment 重新 render 而導致跑馬燈失效
    _titleWidget = CenteredMarquee(
        key: ValueKey(widget.playerItemDtoList[widget.initialIndex].storyId),
        maxWidth: 284.w,
        text: widget.playerItemDtoList[widget.initialIndex].storyName,
        color: ConfigColor.textColorDefault,
        fontWeight: FontWeight.bold,
        fontSize: 24.w);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      collectionController!.checkCollected(
          widget.playerItemDtoList[widget.initialIndex].channelId);
      if (widget.isNewPlayerItem) {
        ref.watch(storyStateProvider.notifier).state = null;
        if (widget.playerItemDtoList[widget.initialIndex].isPremium) {
          playerController!
              .checkPaid(widget.playerItemDtoList[widget.initialIndex]);
        }
        playerController!
            .initNewStat(widget.playerItemDtoList[widget.initialIndex]);
      } else {
        playerController!
            .initStream(widget.playerItemDtoList[widget.initialIndex].storyId);
      }
      initInstantComment();
      playerController!.getInteractiveContent();
      playerController!
          .initVoiceMessageStatus(widget.initialIndex, widget.isNewPlayerItem);
    });
  }

  void initInstantComment() async {
    commentController!.clearInstantQueue();
    await commentController!.getInstantComments(
        widget.playerItemDtoList[widget.initialIndex].storyId);
    _instantCommentTimer?.cancel();
    _instantCommentTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      commentController!.fireInstantComment(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ref.watch(isForegroundProvider.notifier).state =
        state == AppLifecycleState.resumed;

    if (state == AppLifecycleState.resumed) {
      initInstantComment();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _instantCommentTimer?.cancel();
      _instantCommentTimer = null;
    }
  }

  void initProviders() {
    ref.watch(isCollectedProvider.notifier).state = null;
    ref.watch(interactiveMessageInfoIndexProvider.notifier).state = null;
    ref.watch(instantCommentListProvider.notifier).state = null;
    ref.watch(interactiveMessageInfoListProvider.notifier).state = null;
    if (actPodAudioHandler?.mediaItem.value?.id ==
        widget.playerItemDtoList[widget.initialIndex].storyId) {
      ref.watch(isShowingInteractiveContentProvider.notifier).state =
          ref.watch(isPlayingInteractiveContentProvider);
    } else {
      ref.watch(isShowingInteractiveContentProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    playerController!.cancelStreamingFunction();
    commentController!.dispose();
    _commentFocusNode.removeListener(_handleCommentFocusChange);
    _commentFocusNode.dispose();
    _instantCommentFocusNode.removeListener(_handleInstantCommentFocusChange);
    _instantCommentFocusNode.dispose();
    _instantCommentTimer?.cancel();
    _instantCommentTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: ConfigColor.background,
        appBar: AppBar(
            surfaceTintColor: Colors.white,
            toolbarHeight: 40.h,
            titleSpacing: 0.0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
              ),
              iconSize: 20.w,
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _titleWidget,
                const Spacer(),
                ShareButton(
                  storyInfo: widget.playerItemDtoList[widget.initialIndex],
                ),
                const Spacer(),
              ],
            ),
            backgroundColor: ConfigColor.background,
            elevation: 0),
        body: SafeArea(
            child: Stack(
          children: [
            mainPage(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0.h,
              child: PlayerBox(
                  playerController!,
                  thumbsController!,
                  commentController!,
                  widget.playerItemDtoList[widget.initialIndex]),
            )
          ],
        )));
  }

  Widget mainPage() {
    return SizedBox(
        height: ScreenUtil().screenHeight,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16.h,
                ),
                UserInfoBarWidget(
                  collectionController: collectionController!,
                  storyInfo: widget.playerItemDtoList[widget.initialIndex],
                ),
                SizedBox(
                  height: 12.h,
                ),
                ImageInstantComment(
                  storyInfo: widget.playerItemDtoList[widget.initialIndex],
                  commentController: commentController!,
                ),
                SizedBox(
                  height: 16.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SendMessageButton(
                      playerController: playerController!,
                      storyInfo: widget.playerItemDtoList[widget.initialIndex],
                    ),
                    Visibility(
                        visible: widget.playerItemDtoList[widget.initialIndex]
                                .voiceMessageStatus ==
                            "enable",
                        child: SizedBox(
                          width: 6.w,
                        )),
                    InstantCommentButton(
                      focusNode: _instantCommentFocusNode,
                      commentController: commentController!,
                      storyInfo: widget.playerItemDtoList[widget.initialIndex],
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    InstantCommentSwitch()
                  ],
                ),
                SizedBox(
                  height: 16.h,
                ),
                AboutStory(
                  storyInfo: widget.playerItemDtoList[widget.initialIndex],
                ),
                SizedBox(
                  height: 16.h,
                ),
                CommentSection(
                    commentController: commentController!,
                    focusNode: _commentFocusNode,
                    storyInfo: widget.playerItemDtoList[widget.initialIndex]),
                SizedBox(
                  height: 16.h,
                ),
                ReportAndHiddenButton(
                  storyId:
                      widget.playerItemDtoList[widget.initialIndex].storyId,
                ),
                SizedBox(
                  height: 132.h,
                ),
              ],
            ),
          ),
        ));
  }
}
