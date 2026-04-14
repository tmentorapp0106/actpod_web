import 'dart:async';
import 'dart:html' as html;

import 'package:actpod_web/components/actpod_back_button.dart';
import 'package:actpod_web/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/components/bulletin_preview.dart';
import 'package:actpod_web/features/live_page/components/chat_messages.dart';
import 'package:actpod_web/features/live_page/components/listen_only/member_count.dart';
import 'package:actpod_web/features/live_page/components/listen_only/player_status.dart';
import 'package:actpod_web/features/live_page/components/listen_only/progress_bar.dart';
import 'package:actpod_web/features/live_page/components/listen_only/story_info.dart';
import 'package:actpod_web/features/live_page/controllers/coins_controller.dart';
import 'package:actpod_web/features/live_page/controllers/member_controller.dart';
import 'package:actpod_web/features/live_page/controllers/message_controller.dart';
import 'package:actpod_web/features/live_page/controllers/player_controller.dart';
import 'package:actpod_web/features/live_page/controllers/room_controller.dart';
import 'package:actpod_web/features/live_page/dto/check_room.dart';
import 'package:actpod_web/features/live_page/dto/room_action.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/services/ws_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/play_service.dart';

class ListenOnlyScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String storyId;

  const ListenOnlyScreen({required this.roomId, required this.storyId});

  @override
  _ListenOnlyScreenState createState() => _ListenOnlyScreenState();
}

class _ListenOnlyScreenState extends ConsumerState<ListenOnlyScreen> {
  final PlayService playService = PlayService(AudioPlayer());
  final FocusNode focusNode = FocusNode();
  final WsService _wsService = WsService(wsBaseUrl: dotenv.env["WS_SERVER_URL"]?? "");
  final StreamController<void> thumbReactionStream = StreamController<void>.broadcast();
  final StreamController<RoomActionDto> roomStream = StreamController<RoomActionDto>.broadcast();
  CoinsController? coinsController;
  RoomController? roomController;
  MessageController? messageController;
  PlayerController? playerController;
  MemberController? memberController;
  

  @override
  void initState() {
    super.initState();
    coinsController = CoinsController(ref);
    roomController = RoomController(ref, roomStream, null, null, playService);
    playerController = PlayerController(ref, playService);
    messageController = MessageController(ref, _wsService, playService, roomStream, thumbReactionStream, null, null, null);
    memberController = MemberController(ref, roomStream, null);
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      initProviders();
      roomController!.getRoomInfo(widget.roomId);
      playerController!.initPlayer(widget.storyId);
      roomController!.getStickers();
      await checkLogin();
      bool openedDeepLink = await checkOpenDeepLink();
      if(openedDeepLink) {
        html.window.location.href = 'about:blank';
        return;
      }
      final checkRoomRes = await roomController!.checkRoomInfo(widget.roomId);
      if(checkRoomRes == CheckRoomRes.error) {
        ToastService.showNoticeToast("房間已關閉");
        myRouter.pop();
        return;
      } else if(checkRoomRes == CheckRoomRes.full) {
        ToastService.showNoticeToast("房間已額滿");
        myRouter.pop();
        return;
      } else if(checkRoomRes == CheckRoomRes.duplicate) {
        ToastService.showNoticeToast("您的帳號已在房間中");
        myRouter.pop();
        return;
      }
      roomController!.initRoomStreamController(roomId: widget.roomId);
      roomController!.getBulletins(widget.roomId);
      String userId = UserPrefs.getUserInfo()?.userId?? "";
      memberController!.initMemberStreamController();
      await messageController!.initWebsocket(userId);
      messageController!.sendJoinRoomCmd(userId, widget.storyId, widget.roomId);
    });
  }

  Future<void> checkLogin() async {
    while (ref.read(userInfoProvider) == null) {
      final bool? loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // prevent tap outside to close
        builder: (context) {
          return LoginScreen();
        },
      );

      // If dialog somehow closes without success, keep showing it
      if (loggedIn == true && ref.read(userInfoProvider) != null) {
        break;
      }
    }
  }

  Future<bool> checkOpenDeepLink() async {
    String url;
    if(kIsWeb) {
      bool? goto = await showDialog<bool>(
        context: context,
        builder: (context) => LaunchDeepLinkDialog(),
      );
      if(goto != null && goto) {
        await Future.delayed(const Duration(microseconds: 500));
        url = "https://actpod-488af.web.app/live/link/listen_together/${widget.roomId}/${widget.roomId}?openExternalBrowser=1";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
        return true;
      }
    }
    return false;
  }

  void initProviders() {
    ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    playService.dispose();
    messageController?.dispose();
    messageController = null;
    playerController?.dispose();
    playerController = null;
    memberController?.dispose();
    memberController = null;
    roomController?.dispose();
    roomController = null;
    if(!thumbReactionStream.isClosed) {
      thumbReactionStream.close();
    }
    if(!roomStream.isClosed) {
      roomStream.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    Widget body;
    final roomInfo = ref.watch(roomInfoProvider);
    if(roomInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if(roomInfo.roomId.isEmpty) {
      body = Center(
        child: Text(
          "找不到房間",
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

  Widget mobileScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    LiveProgressBar(isHost: false, messageController: messageController!,),
                    PlayerStatus()
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MemberCount(),
                  const SizedBox(width: 12,)
                ],
              ),
              BulletinPreview(
                roomController: roomController!,
                messageController: messageController!,
              ),
              Expanded(
                child: ChatMessagesView(userId: UserPrefs.getUserInfo()?.userId?? "", messageController: messageController!, focusNode: focusNode,),
              )
            ],
          ),
        ),
      )
    );
  }
}