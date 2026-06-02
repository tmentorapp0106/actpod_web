import 'dart:async';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/invite_dialog.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/revoke_mic_dialog.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/start_live_button.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/member_count.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/mic_section.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/story_name.dart';
import 'package:quick_share_app/features/live_feature/components/kickout_dialog.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/room_controller.dart';
import 'package:quick_share_app/services/permission_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/services/ws_service.dart';
import 'package:quick_share_app/features/live_feature/services/play_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../components/back_button.dart';
import '../../../../dto/live_room_member_dto.dart';
import '../../../../main.dart';
import '../../../../router.dart';
import '../../../../services/toast_service.dart';
import '../../components/background_paused_dialog.dart';
import '../../components/bulletin_preview.dart';
import '../../components/confirm_leaving_dialog.dart';
import '../../components/interactive/host/player_buttons.dart';
import '../../components/interactive/progress_bar.dart';
import '../../components/interactive/title.dart';
import '../../components/interactive/story_image.dart';
import '../../components/interactive/host/chat_messages.dart';
import '../../controllers/member_controller.dart';
import '../../dto/check_room_res.dart';
import '../../dto/mic_action_dto.dart';
import '../../dto/room_action_dto.dart';
import '../../dto/ws_message_dto.dart';
import '../../providers.dart';

class HostInteractiveScreen extends ConsumerStatefulWidget {
  final String roomId; // for rejoin usage
  final String storyId;
  final String title;
  final int capacity;
  final bool notifyFans;
  final int notyetOwnedStoryPrice;
  final int alreadyOwnedStoryPrice;

  HostInteractiveScreen({
    required this.roomId,
    required this.storyId,
    required this.title,
    required this.capacity,
    required this.notifyFans,
    required this.notyetOwnedStoryPrice,
    required this.alreadyOwnedStoryPrice
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return HostInteractiveScreenState();
  }
}

class HostInteractiveScreenState extends ConsumerState<HostInteractiveScreen> {
  AppLifecycleListener? _listener;
  final FocusNode focusNode = FocusNode();
  final StreamController<RoomActionDto> roomStream = StreamController<RoomActionDto>.broadcast();
  final StreamController<MicPermissionAction> micPermissionRoomStream = StreamController<MicPermissionAction>.broadcast();
  final StreamController<void> thumbReactionStream = StreamController<void>.broadcast();
  final StreamController<LiveKitCmd> livekitStream = StreamController<LiveKitCmd>.broadcast();
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
    messageController = MessageController(ref, actPodAudioHandler!.wsService, roomStream, micPermissionRoomStream, thumbReactionStream, livekitStream, memberActionStream);
    memberController = MemberController(ref, roomStream, livekitStream);
    roomController = RoomController(ref, roomStream, micPermissionRoomStream, livekitStream);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      roomController!.getStickers();
      roomController!.getBackgroundMusics();
      PermissionService.checkMicPermission();
      String userId = UserService.getUserInfo()?.userId?? "";
      memberController!.initMemberStreamController();
      roomController!.initRoomStreamController(isHost: true);
      await messageController!.initWebsocket(userId);
      await playerController!.initPlayer(widget.storyId);
      await Future.delayed(Duration(milliseconds: 1000));
      messageController!.sendOpenRoomCmd(widget.roomId, userId, widget.storyId, widget.title, "interactive", widget.capacity, widget.notifyFans, widget.notyetOwnedStoryPrice, widget.alreadyOwnedStoryPrice);

      _memberActionSub = memberActionStream.stream.listen((memberAction) {
        if (!mounted) return;
        if(memberAction.memberAction == MemberAction.attemptToSendInvitation) {
          showDialog(
            context: this.context,
            builder: (context) {
              return InviteDialog(
                memberInfo: memberAction.memberInfo!,
                onSendInvitation: () {
                  messageController!.sendInviteMic(memberAction.memberInfo!.userId);
                },
                onKickOutRoom: () {
                  messageController!.sendKickOutRoom(memberAction.memberInfo!.userId);
                },
              );
            }
          );
        }
        if(memberAction.memberAction == MemberAction.attemptToKickout) {
          showDialog(
            context: this.context,
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
        if(memberAction.memberAction == MemberAction.attemptToRevokeMic) {
          showDialog(
            context: this.context,
            builder: (context) {
              return RevokeMicDialog(
                memberInfo: memberAction.memberInfo!,
                onRevokeMic: () {
                  messageController!.sendRevokeMic(memberAction.memberInfo!.userId);
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
    ref.watch(onMicProvider.notifier).state = false;
    ref.watch(interactiveRoomModeProvider.notifier).state = InteractiveRoomMode.inactive;
    ref.watch(onMicMembersProvider.notifier).state = [];
    ref.watch(storyInfoProvider.notifier).state = null;
    ref.watch(currentPositionProvider.notifier).state = Duration.zero;
    ref.watch(roomMembersProvider.notifier).state = [];
    ref.watch(chatMessagesProvider.notifier).state = [];
    ref.watch(roomInfoProvider.notifier).state = null;
    ref.watch(podcastPlayerStatusProvider.notifier).state = PodcastPlayerStatus.initializing;
    ref.watch(bulletinsProvider.notifier).state = [];
    ref.watch(backgroundMusicsProvider.notifier).state = [];
    ref.watch(playingBackgroundMusicUrlProvider.notifier).state = "";
    ref.watch(livekitConnectionStateProvider.notifier).state = livekit_client.ConnectionState.disconnected;
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
    if(!micPermissionRoomStream.isClosed) {
      micPermissionRoomStream.close();
    }
    if(!memberActionStream.isClosed) {
      memberActionStream.close();
    }
    if(!thumbReactionStream.isClosed) {
      thumbReactionStream.close();
    }
    if(!livekitStream.isClosed) {
      livekitStream.close();
    }
    _memberActionSub?.cancel();
    _memberActionSub = null;
  }

  void share() {
    final roomInfo = ref.read(roomInfoProvider);
    if(roomInfo == null) {
      return;
    }

    final box = this.context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: 'https://web.actpodapp.com/live/interactive/${roomInfo.roomId}/${roomInfo.storyId}?openExternalBrowser=1',
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

          if (context.mounted) {
            router.pop();
          }
        }
      },
      child:Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(28), // 你要多矮就改這個
          child: AppBar(
            leading: ActPodBackButton(
              pressFunction: () async {
                bool? leave = await ConfirmLeavingDialog().show(context);
                if(leave != null && leave) {
                  await messageController!.sendCloseRoom();
                  await actPodAudioHandler!.wsService.close();
                  router.pop();
                }
              },
            ),
            leadingWidth: 60,
            titleSpacing: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: RoomTitle(),
            toolbarHeight: 28, // 建議也一起設，確保一致
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
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          StoryImage(),
                          const SizedBox(width: 8,),
                          Expanded(
                            child: SizedBox(
                              height: 80.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StoryName(isHost: true),
                                  const SizedBox(height: 4,),
                                  PlayerButtons(messageController!, playerController!)
                                ]
                              )
                            )
                          )
                        ],
                      ),
                      const SizedBox(height: 8,),
                      LiveProgressBar(
                        isHost: true, messageController: messageController!,
                      ),
                      Visibility(
                        visible: ref.watch(interactiveRoomModeProvider) == InteractiveRoomMode.inactive,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: StartLiveButton(messageController: messageController!,)
                            ),
                            Align(
                              alignment: Alignment(0.9, 0.0),
                              child: MemberCount(
                                memberActionStream: memberActionStream,
                              ),
                            ),
                          ],
                        )
                      ),
                      Visibility(
                        visible: ref.watch(interactiveRoomModeProvider) == InteractiveRoomMode.active,
                        child: MicSection(
                          messageController: messageController!,
                          micPermissionRoomStream: micPermissionRoomStream,
                          memberActionStream: memberActionStream,
                        )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8,),
                BulletinPreview(
                  screen: "interactive_host",
                  roomController: roomController!,
                  messageController: messageController!,
                ),
                Expanded(
                  child: ChatMessagesView(userId: UserService.getUserInfo()?.userId?? "", messageController: messageController!, focusNode: focusNode, roomController: roomController!,),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}