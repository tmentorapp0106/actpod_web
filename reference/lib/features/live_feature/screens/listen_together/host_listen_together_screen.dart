import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/live_feature/components/background_paused_dialog.dart';
import 'package:quick_share_app/features/live_feature/components/confirm_leaving_dialog.dart';
import 'package:quick_share_app/features/live_feature/components/listen_together/host/player_buttons.dart';
import 'package:quick_share_app/features/live_feature/components/listen_together/progress_bar.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/room_controller.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/services/ws_service.dart';
import 'package:quick_share_app/features/live_feature/services/play_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../components/back_button.dart';
import '../../../../dto/live_room_member_dto.dart';
import '../../../../main.dart';
import '../../components/bulletin_preview.dart';
import '../../components/listen_together/host/member_count.dart';
import '../../components/listen_together/host/chat_messages.dart';
import '../../components/kickout_dialog.dart';
import '../../components/listen_together/story_info.dart';
import '../../controllers/member_controller.dart';
import '../../dto/check_room_res.dart';
import '../../dto/mic_action_dto.dart';
import '../../dto/room_action_dto.dart';
import '../../providers.dart';

class HostListenTogetherScreen extends ConsumerStatefulWidget {
  final String roomId; // for rejoin usage
  final String storyId;
  final String title;
  final bool notifyFans;
  final int notyetOwnedStoryPrice;
  final int alreadyOwnedStoryPrice;

  HostListenTogetherScreen({
    required this.roomId,
    required this.storyId,
    required this.title,
    required this.notifyFans,
    required this.notyetOwnedStoryPrice,
    required this.alreadyOwnedStoryPrice
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return HostListenTogetherScreenState();
  }
}

class HostListenTogetherScreenState extends ConsumerState<HostListenTogetherScreen> {
  AppLifecycleListener? _listener;
  final FocusNode focusNode = FocusNode();
  final StreamController<RoomActionDto> roomStream = StreamController<RoomActionDto>.broadcast();
  final StreamController<void> thumbReactionStream = StreamController<void>.broadcast();
  final StreamController<MemberActionDto> memberActionStream = StreamController<MemberActionDto>.broadcast();
  StreamSubscription<MemberActionDto>? _memberActionSub;
  MessageController? messageController;
  PlayerController? playerController;
  MemberController? memberController;
  RoomController? roomController;
  bool playerInitialed = false;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onPause: _handleGoBackground,
      onHide: _handleGoBackground,
      onDetach: _handleGoBackground,
      onResume: _handleBackToForeground,
    );
    WakelockPlus.enable();
    playerController = PlayerController(ref);
    messageController = MessageController(ref, actPodAudioHandler!.wsService, roomStream, null, thumbReactionStream, null, null);
    memberController = MemberController(ref, roomStream, null);
    roomController = RoomController(ref, roomStream, null, null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      roomController!.getStickers();
      roomController!.getBackgroundMusics();
      String userId = UserService.getUserInfo()?.userId?? "";
      roomController!.initRoomStreamController(isHost: true);
      memberController!.initMemberStreamController();
      await messageController!.initWebsocket(userId);
      await playerController!.initPlayer(widget.storyId);
      messageController!.sendOpenRoomCmd(widget.roomId, userId, widget.storyId, widget.title, "listenOnly", 100, widget.notifyFans, widget.notyetOwnedStoryPrice, widget.alreadyOwnedStoryPrice);

      _memberActionSub = memberActionStream.stream.listen((memberAction) {
        if (!mounted) return;
        if(memberAction.memberAction == MemberAction.attemptToKickout) {
          showDialog(
            context: context,
            builder: (context) {
              return KickoutDialog(
                memberInfo: memberAction.memberInfo!,
                onKickOutRoom: () {
                  messageController!.sendKickOutRoom(memberAction.memberInfo!.userId);
                },
              );
            }
          );
        }
      });
    });
  }

  void _handleGoBackground() {
    messageController!.sendToBackground();
  }

  Future<void> _handleBackToForeground() async {
    final checkRoomRes = await roomController!.backRoom(ref.watch(roomInfoProvider)?.roomId?? "", isHost: true);
    if(checkRoomRes == BackRoomRes.error) {
      ToastService.showNoticeToast("房間已關閉");
      await actPodAudioHandler!.wsService.close();
      router.go("/");
      return;
    }
    if(checkRoomRes == BackRoomRes.left) {
      ToastService.showNoticeToast("您已離開房間");
      await actPodAudioHandler!.wsService.close();
      router.go("/");
      return;
    }
    messageController!.sendToForeground();
  }

  void initProviders() {
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(currentPositionProvider.notifier).state = Duration.zero;
    ref.watch(roomMembersProvider.notifier).state = [];
    ref.watch(chatMessagesProvider.notifier).state = [];
    ref.watch(roomInfoProvider.notifier).state = null;
    ref.watch(podcastPlayerStatusProvider.notifier).state = PodcastPlayerStatus.initializing;
    ref.watch(bulletinsProvider.notifier).state = [];
    ref.watch(backgroundMusicsProvider.notifier).state = [];
    ref.watch(livekitConnectionStateProvider.notifier).state = livekit_client.ConnectionState.disconnected;
    ref.watch(playingBackgroundMusicUrlProvider.notifier).state = "";
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    WakelockPlus.disable();
    _listener?.dispose();
    _listener = null;
    messageController?.dispose();
    messageController = null;
    playerController?.dispose();
    playerController = null;
    memberController?.dispose();
    memberController = null;
    roomController?.dispose();
    roomController = null;
    if(!roomStream.isClosed) {
      roomStream.close();
    }
    _memberActionSub?.cancel();
    _memberActionSub = null;
    if(!memberActionStream.isClosed) {
      memberActionStream.close();
    }
    if(!thumbReactionStream.isClosed) {
      thumbReactionStream.close();
    }
  }

  void share() {
    final roomInfo = ref.read(roomInfoProvider);
    if(roomInfo == null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: 'https://web.actpodapp.com/live/listenOnly/${roomInfo.roomId}/${roomInfo.storyId}?openExternalBrowser=1',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final leave = await ConfirmLeavingDialog().show(context);

        if (leave == true) {
          await messageController!.sendCloseRoom();
          await actPodAudioHandler!.wsService.close();
          await actPodAudioHandler!.wsService.dispose();

          if (context.mounted) {
            router.pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(28), // 你要多矮就改這個
          child: AppBar(
            leading: ActPodBackButton(
              pressFunction: () async {
                bool? leave = await ConfirmLeavingDialog().show(context);
                if(leave != null && leave) {
                  await messageController!.sendCloseRoom();
                  await messageController!.closeWs();
                  router.pop();
                }
              },
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 28,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 8),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: share,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            focusNode.unfocus();
          },
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StoryInfo(),
                      const SizedBox(height: 4,),
                      LiveProgressBar(isHost: true, messageController: messageController!,),
                      const SizedBox(height: 4,),
                      PlayerButtons(messageController!, playerController!),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MemberCount(memberActionStream: memberActionStream,),
                    const SizedBox(width: 12,)
                  ],
                ),
                BulletinPreview(
                  screen: "listen_together_host",
                  roomController: roomController!,
                  messageController: messageController!
                ),

                Expanded(
                  child: ChatMessagesView(
                    userId: UserService.getUserInfo()?.userId?? "",
                    messageController: messageController!,
                    focusNode: focusNode,
                    roomController: roomController!
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}