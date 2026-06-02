import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/audience/mic_invitation_dialog.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/room_controller.dart';
import 'package:quick_share_app/features/live_feature/dto/check_room_res.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/services/ws_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../apiManagers/live_api_dto/exist_ticket.dart';
import '../../../../apiManagers/live_api_dto/get_price_rule.dart';
import '../../../../apiManagers/live_system_api_manager.dart';
import '../../../../apiManagers/purchase_api_dto/purchase_live_room_ticket_res.dart';
import '../../../../apiManagers/purchase_system_api_manager.dart';
import '../../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../../apiManagers/story_system_api_manager.dart';
import '../../../../components/back_button.dart';
import '../../../../dto/live_room_dto.dart';
import '../../../../providers.dart';
import '../../../../services/permission_service.dart';
import '../../components/background_paused_dialog.dart';
import '../../components/bulletin_preview.dart';
import '../../components/collect_button.dart';
import '../../components/confirm_leaving_dialog.dart';
import '../../components/interactive/audience/mic_section.dart';
import '../../components/interactive/audience/player_status.dart';
import '../../components/interactive/audience/member_count.dart';
import '../../components/interactive/story_name.dart';
import '../../components/interactive/story_image.dart';
import '../../components/interactive/title.dart';
import '../../components/interactive/audience/chat_messages.dart';
import '../../components/ticket_dialog.dart';
import '../../controllers/collection_controller.dart';
import '../../controllers/member_controller.dart';
import '../../dto/mic_action_dto.dart';
import '../../dto/purchase_ticket_enum.dart';
import '../../dto/room_action_dto.dart';
import '../../dto/ws_message_dto.dart';
import '../../providers.dart';

class AudienceInteractiveScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String storyId;

  AudienceInteractiveScreen({
    required this.roomId,
    required this.storyId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AudienceInteractiveScreenState();
  }
}

class AudienceInteractiveScreenState extends ConsumerState<AudienceInteractiveScreen> {
  AppLifecycleListener? _listener;
  final StreamController<RoomActionDto> roomStream = StreamController<RoomActionDto>.broadcast();
  final StreamController<MicPermissionAction> micPermissionRoomStream = StreamController<MicPermissionAction>.broadcast();
  final StreamController<void> thumbReactionStream = StreamController<void>.broadcast();
  final StreamController<LiveKitCmd> livekitStream = StreamController<LiveKitCmd>.broadcast();
  final StreamController<MemberActionDto> memberActionStream = StreamController<MemberActionDto>.broadcast();
  StreamSubscription<MemberActionDto>? _memberActionSub;
  final FocusNode focusNode = FocusNode();
  MessageController? messageController;
  PlayerController? playerController;
  MemberController? memberController;
  RoomController? roomController;
  CollectionController? collectionController;

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
    PermissionService.checkMicPermission();
    roomController = RoomController(ref, roomStream, micPermissionRoomStream, livekitStream);
    playerController = PlayerController(ref);
    messageController = MessageController(ref, actPodAudioHandler!.wsService, roomStream, micPermissionRoomStream, thumbReactionStream, livekitStream, memberActionStream);
    memberController = MemberController(ref, roomStream, livekitStream);
    collectionController = CollectionController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      roomController!.getStickers();
      final checkRoomRes = await roomController!.checkRoomInfo(widget.roomId, isHost: false);
      if(checkRoomRes == CheckRoomRes.error) {
        ToastService.showNoticeToast("房間已關閉");
        router.pop();
        return;
      } else if(checkRoomRes == CheckRoomRes.full) {
        ToastService.showNoticeToast("房間已額滿");
        router.pop();
        return;
      } else if(checkRoomRes == CheckRoomRes.duplicate) {
        ToastService.showNoticeToast("您的帳號已在房間中");
        router.pop();
        return;
      }
      LiveRoomDto room = ref.read(roomInfoProvider)!;
      collectionController!.checkCollected(room.channelId);
      if(room.needTicket) {
        ref.watch(loadingProvider.notifier).state = true;
        ExistTicketRes existTicketRes = await liveApiManager.existTicket(room.roomId, UserService.getUserInfo()!.userId);
        if(existTicketRes.code != "0000") {
          ref.watch(loadingProvider.notifier).state = false;
          router.pop();
          return;
        }
        if(!existTicketRes.existTicket!) {
          GetOneStoryRes storyRes = await storyApiManager.getOneStory(room.storyId);
          if(storyRes.code != "0000") {
            ref.watch(loadingProvider.notifier).state = false;
            router.pop();
            return;
          }
          GetPriceRuleRes ruleResponse = await liveApiManager.getPriceRule(room.roomId);
          if(ruleResponse.code != "0000") {
            ref.watch(loadingProvider.notifier).state = false;
            router.pop();
            return;
          }
          if(!context.mounted) {
            router.pop();
            return;
          }
          int requiredPodCoins = storyRes.story!.isPremium? ruleResponse.priceRule!.alreadyBoughtStory : ruleResponse.priceRule!.notyetBoughtStory;
          PurchaseTicketEnum? purchase = await TicketDialog().showPaidLiveRoomDialog(context: context, requiredPodcoins: requiredPodCoins, currentPodcoins: ref.watch(userPodCoinsProvider));
          if(purchase != null && purchase == PurchaseTicketEnum.purchase) {
            ref.watch(loadingProvider.notifier).state = true;
            PurchaseLiveRoomTicketRes purchaseLiveRoomTicketRes = await purchaseApiManager.purchaseLiveRoomTicket(UserService.getUserInfo()!.userId, room.roomId, room.hostId, requiredPodCoins);
            if(purchaseLiveRoomTicketRes.code != "0000") {
              ToastService.showNoticeToast("購票失敗");
              ref.watch(loadingProvider.notifier).state = false;
              router.pop();
              return;
            }
            existTicketRes = await liveApiManager.existTicket(room.roomId, UserService.getUserInfo()!.userId);
            if(existTicketRes.code != "0000") {
              ref.watch(loadingProvider.notifier).state = false;
              router.pop();
              return;
            }
          } else if(purchase != null && purchase == PurchaseTicketEnum.notEnough) {
            ref.watch(loadingProvider.notifier).state = false;
            router.pop(PurchaseTicketEnum.notEnough);
            return;
          } else {
            ref.watch(loadingProvider.notifier).state = false;
            router.pop();
            return;
          }
        }
      }
      ref.watch(loadingProvider.notifier).state = false;

      roomController!.initRoomStreamController(isHost: false);
      roomController!.getBulletins(widget.roomId);
      String userId = UserService.getUserInfo()?.userId?? "";
      memberController!.initMemberStreamController();
      await messageController!.initWebsocket(userId);
      await playerController!.initPlayer(widget.storyId);
      messageController!.sendJoinRoomCmd(userId, widget.storyId, widget.roomId);

      _memberActionSub = memberActionStream.stream.listen((memberAction) {
        if (!mounted) return;
        if(memberAction.memberAction == MemberAction.receivedInvitation) {
          showDialog(
            context: context,
            builder: (context) {
              return MicInviteDialog(
                onAccept: () {
                  messageController!.sendAcceptInviteMic();
                },
                onReject: () {},
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
    final checkRoomRes = await roomController!.backRoom(widget.roomId, isHost: false);
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
    ref.watch(handsUpProvider.notifier).state = false;
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
    ref.watch(livekitConnectionStateProvider.notifier).state = livekit_client.ConnectionState.disconnected;
    ref.watch(isCollectedProvider.notifier).state = null;
    ref.watch(playingBackgroundMusicUrlProvider.notifier).state = "";
    ref.watch(isHostedProvider.notifier).state = null;
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
    if(!thumbReactionStream.isClosed) {
      thumbReactionStream.close();
    }
    if(!livekitStream.isClosed) {
      livekitStream.close();
    }
    if(!memberActionStream.isClosed) {
      memberActionStream.close();
    }

    _memberActionSub?.cancel();
    _memberActionSub = null;
  }

  void share() {
    final roomInfo = ref.read(roomInfoProvider);
    if(roomInfo == null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
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
          await messageController!.sendLeaveRoom();
          await actPodAudioHandler!.wsService.close();

          if (context.mounted) {
            router.pop();
          }
        }
      },
      child:WholePageLoading(
        provider: loadingProvider,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(28), // 你要多矮就改這個
            child: AppBar(
              leading: ActPodBackButton(
                pressFunction: () async {
                  bool? leave = await ConfirmLeavingDialog().show(context);
                  if(leave != null && leave) {
                    await messageController!.sendLeaveRoom();
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
              toolbarHeight: 28,
              actions: [
                CollectButton(collectionController: collectionController!,),
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
                                    PlayerStatus()
                                  ]
                                )
                              )
                            )
                          ],
                        ),
                        Visibility(
                            visible: ref.watch(interactiveRoomModeProvider) == InteractiveRoomMode.inactive,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment(0.9, 0.0),
                                  child: MemberCount(),
                                ),
                              ],
                            )
                        ),
                        Visibility(
                          visible: ref.watch(interactiveRoomModeProvider) == InteractiveRoomMode.active,
                          child: MicSection(messageController: messageController!, micPermissionRoomStream: micPermissionRoomStream)
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8,),
                  BulletinPreview(
                    screen: "interactive_audience",
                    roomController: roomController!,
                    messageController: messageController!,
                  ),
                  Expanded(
                    child: ChatMessagesView(userId: UserService.getUserInfo()?.userId?? "", messageController: messageController!, focusNode: focusNode,),
                  )
                ],
              ),
            ),
          )
        )
      )
    );
  }
}