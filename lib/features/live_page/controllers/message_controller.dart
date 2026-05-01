import 'dart:async';
import 'dart:convert';

import 'package:actpod_web/api_manager/live_api_manager.dart';
import 'package:actpod_web/api_manager/live_dto/get_bulletins.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/features/live_page/dto/chat.dart';
import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:actpod_web/features/live_page/dto/member_action.dart';
import 'package:actpod_web/features/live_page/dto/room_action.dart';
import 'package:actpod_web/features/live_page/dto/ws_message.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/features/live_page/services/play_service.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/services/ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../api_manager/purchase_dto/get_user_purses.dart';

class MessageController {
  WidgetRef ref;
  WsService wsService;
  bool enteredRoom = false;
  PlayService playService;
  StreamController<RoomActionDto> roomActionStream;
  StreamController<void> thumbReactionStream;
  StreamController<LiveKitCmd>? livekitStream;
  StreamController<MicPermissionAction>? micPermissionStream;
  StreamController<MemberActionDto>? micActionStream;
  StreamSubscription<Map<String, dynamic>>? _sub;
  StreamSubscription<bool>? _connSub;
  Timer? _updatePlayerSyncTimer;
  String? _userId;
  String? roomId;
  String? _storyId;
  final String _clientType = "audience";
  bool initialedPosition = false;

  MessageController(this.ref, this.wsService, this.playService, this.roomActionStream, this.thumbReactionStream, this.livekitStream, this.micPermissionStream, this.micActionStream);

  Future<void> initWebsocket(String userId) async {
    await wsService.connect(path: "/live/ws?userId=$userId");

    _connSub = wsService.connected.listen((isConnected) {
      if (!isConnected) return;
      _autoRejoin();
    });

    _sub = wsService.messages.listen((msg) async {
        WsMessageDto message  = WsMessageDto.fromJson(msg);
        switch(message.cmd){
        case "accessRoom":
            LiveRoomMemberDto member = LiveRoomMemberDto.fromJsonString(message.content);
            ToastService.showSuccessToast("${member.nickname} 加入房間了！");
            roomActionStream.add(RoomActionDto(action: RoomAction.join, member: member));
            return;
        case "leaveRoom":
          handleLeaveRoom(message);
          return;

        case "playPodcast":
          handlePlayPodcast();
        return;
        case "pausePodcast":
          playService.pauseAudio();
        return;
        case "seekPosition":
          handleSeekPosition(message.content);
        return;
        case "joinRoomSuccess":
          handleJoinRoomSuccess();
          return;
        case "getRoomPlayer":
          if(_clientType == "host") {
            return;
          }
          final playerStatus = message.params[0];
          final position = int.tryParse(message.params[1]);
          String? backgroundMusicUrl;
          if(message.params.length > 2) {
            backgroundMusicUrl = message.params[2];
          }
          handlePlayer(playerStatus, position?? 0, backgroundMusicUrl);
          return;
        case "sendChat":
          handleChatMessage(message);
          return;
        case "sendThumb":
          thumbReactionStream.add(null);
          return;
        case "closeRoom":
          playService.stopAudio();
          ToastService.showNoticeToast("Podcaster 關閉了房間");
          myRouter.go("/");
          return;
        case "kickOutRoom":
          playService.stopAudio();
          ToastService.showNoticeToast("您被踢出房間");
          myRouter.go("/");
          return;

        case "startLiveKit":
          handleStartLiveKit(message.roomId);
          return;
        case "stopLiveKit":
          handleStopLiveKit(message.roomId);
          return;


        case "revokeMic":
          micPermissionStream?.add(MicPermissionAction.revoke);
          ToastService.showNoticeToast("下麥");
          return;
        case "updateMic":
          handleUpdateMic(message.content);
          return;
        case "handUp":
          handleHandUp(message.from);
          return;
        case "handDown":
          handleHandDown(message.from);
          return;
        case "inviteMic":
          handleInviteMic(message.params[0]);
          return;
        case "playBackgroundMusic":
          handlePlayBackgroundMusic(message.params[0]);
          return;
        case "stopBackgroundMusic":
          handleStopBackgroundMusic();
          return;

        case "createdBulletin":
          handleCreatedBulletin();
          return;
        case "updatedBulletin":
          handleUpdatedBulletin();
          return;
        case "deletedBulletin":
          handleDeletedBulletin();
          return;

        case "error":
          ToastService.showNoticeToast(message.content);
          return;
        default:
        return;
        }
      },
      onError: (e, st) {
        print('stream error: $e');
      },
      onDone: () {
        print('stream done');
      },
      cancelOnError: false,
    );
  }

  Future<void> handleChatMessage(WsMessageDto wsMessage) async {
    List<LiveRoomMemberDto> members = ref.watch(roomMembersProvider);
    LiveRoomMemberDto? memberInfo;
    for(LiveRoomMemberDto member in members) {
      if(member.userId == wsMessage.from) {
        memberInfo = member;
      }
    }
    if(memberInfo == null) {
      return;
    }

    int? donateAmount;
    String? stickerUrl;
    if(wsMessage.params[0] == "sticker") {
      stickerUrl = wsMessage.params[1];
      donateAmount = int.tryParse(wsMessage.params[2].toString());
    }
    List<ChatMessageDto> chatMessages = ref.watch(chatMessagesProvider);
    chatMessages.add(ChatMessageDto(
      userId: memberInfo.userId,
      nickname: memberInfo.nickname,
      avatarUrl: memberInfo.avatarUrl,
      content: wsMessage.content,
      type: wsMessage.params[0],
      stickerUrl: stickerUrl,
      donateAmount: donateAmount
    ));
    ref.watch(chatMessagesProvider.notifier).state = [...chatMessages];

    if(memberInfo.userId == _userId && wsMessage.params[0] == "sticker") {
      GetUserPursesRes response = await purchaseApiManager.getUserPurses();
      if(response.code != "0000") {
        return;
      }
      ref.watch(userPodCoinsProvider.notifier).state = response.purses!.coinsPurse.podCoins;
    }
  }

  Future<void> handleJoinRoomSuccess() async {
    if(roomId != null) {
      enteredRoom = true;
      roomActionStream.add(RoomActionDto(action: RoomAction.open, params: [roomId!]));
      sendGetPlayer();
    }
  }

  Future<void> handlePlayPodcast() async {
    roomActionStream.add(RoomActionDto(action: RoomAction.stopBackgroundMusic));
    const maxRetries = 5;
    int retryCount = 0;

    while (ref.read(livekitConnectionStateProvider) == ConnectionState.connected &&
        retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 300));
      retryCount++;
    }

    playService.playAudio();
  }

  Future<void> handleSeekPosition(String positionStr) async {
    final position = int.tryParse(positionStr);
    playService.seekPosition(position?? 0);
  }

  Future<void> handlePlayer(String playerStatus, int position, String? backgroundMusicUrl) async {
    if(!initialedPosition) {
      await playService.seekPosition(position);
      initialedPosition = true;
      if (playerStatus == "playing") {
        if (!(playService.isPlaying())) {
          playService.playAudio();
        }
      } else {
        if ((playService.isPlaying())) {
          playService.pauseAudio();
        }
      }

      if(backgroundMusicUrl != null) {
        roomActionStream.add(RoomActionDto(action: RoomAction.playBackgroundMusic, params: [backgroundMusicUrl]));
      }
    }

    final currentPosition = playService.getCurrentPosition();
    final currentSpeed = playService.getSpeed();
    final differ = currentPosition.inMilliseconds - position;
    if(differ < -10000) {
      playService.seekPosition(position);
    } else if(differ < -300) {
      if(currentSpeed != 1.1) {
        playService.setSpeed(1.1);
      }
    } else if(differ > 300) {
      if(currentSpeed != 0.95) {
        playService.setSpeed(0.95);
      }
    } else {
      if(currentSpeed != 1.0) {
        playService.setSpeed(1.0);
      }
    }
  }

  Future<void> handleStartLiveKit(String? roomId) async {
    if(roomId != null) {
      livekitStream?.add(LiveKitCmd(LiveKitAction.start, ""));
    }
  }

  Future<void> handleStopLiveKit(String? roomId) async {
    if(roomId != null) {
      livekitStream?.add(LiveKitCmd(LiveKitAction.stop, ""));
    }
  }

  Future<void> handleUpdateMic(String userIdListStr) async {
    List<String> userIdList = (jsonDecode(userIdListStr) as List).map((e) => e.toString()).toList();
    List<LiveRoomMemberDto> roomMembers = ref.watch(roomMembersProvider);

    List<LiveRoomMemberDto> onMicList = [];
    for (final userId in userIdList) {
      final matches = roomMembers.where((m) => m.userId == userId);
      if (matches.isNotEmpty) {
        onMicList.add(matches.first);
      }
    }
    ref.watch(onMicMembersProvider.notifier).state = onMicList;
  }

  Future<void> handleHandUp(String userId) async {
    List<LiveRoomMemberDto> roomMembers = ref.watch(roomMembersProvider);
    final matches = roomMembers.where((m) => m.userId == userId);
    if (matches.isNotEmpty) {
      matches.first.isHandsUp = true;
      final member = matches.first;
      List<ChatMessageDto> chatMessages = ref.read(chatMessagesProvider);
      chatMessages.add(ChatMessageDto(userId: member.userId, nickname: member.nickname, avatarUrl: member.avatarUrl, content: "", type: "handUp"));
      ref.watch(chatMessagesProvider.notifier).state = [...chatMessages];
      ref.watch(roomMembersProvider.notifier).state = [...roomMembers];
    }
    if(userId == _userId) {
      ref.watch(handsUpProvider.notifier).state = true;
    }
  }

  Future<void> handleHandDown(String userId) async {
    List<LiveRoomMemberDto> roomMembers = ref.watch(roomMembersProvider);
    final matches = roomMembers.where((m) => m.userId == userId);
    if (matches.isNotEmpty) {
      matches.first.isHandsUp = false;
      ref.watch(roomMembersProvider.notifier).state = [...roomMembers];
    }
    if(userId == _userId) {
      ref.watch(handsUpProvider.notifier).state = false;
    }
  }

  Future<void> handleInviteMic(String userId) async {
    List<LiveRoomMemberDto> members = ref.read(roomMembersProvider);
    for(int i = 0; i < members.length; i++) {
      if(members[i].userId == userId) {
        members[i].isHandsUp = false;
      }
    }
    ref.watch(roomMembersProvider.notifier).state = [...members];
    if(userId == _userId) {
      micActionStream?.add(MemberActionDto(memberAction: MemberAction.receivedInvitation));
    }
  }

  Future<void> handlePlayBackgroundMusic(String url) async {
    roomActionStream.add(RoomActionDto(action: RoomAction.playBackgroundMusic, params: [url]));
  }

  Future<void> handleStopBackgroundMusic() async {
    roomActionStream.add(RoomActionDto(action: RoomAction.stopBackgroundMusic));
  }

  Future<void> handleCreatedBulletin() async {
    if(roomId == null) {
      return;
    }
    GetRoomBulletins getRoomBulletins = await liveApiManager.getRoomBulletins(roomId!);
    if(getRoomBulletins.code != "0000") {
      return;
    }
    ref.watch(bulletinsProvider.notifier).state = getRoomBulletins.bulletins;
    ToastService.showSuccessToast("Podcaster 建立了一則公告");
  }

  Future<void> handleUpdatedBulletin() async {
    if(roomId == null) {
      return;
    }
    GetRoomBulletins getRoomBulletins = await liveApiManager.getRoomBulletins(roomId!);
    if(getRoomBulletins.code != "0000") {
      return;
    }
    ref.watch(bulletinsProvider.notifier).state = getRoomBulletins.bulletins;
    ToastService.showSuccessToast("Podcaster 更新了公告");
  }

  Future<void> handleDeletedBulletin() async {
    if(roomId == null) {
      return;
    }
    GetRoomBulletins getRoomBulletins = await liveApiManager.getRoomBulletins(roomId!);
    if(getRoomBulletins.code != "0000") {
      return;
    }
    ref.watch(bulletinsProvider.notifier).state = getRoomBulletins.bulletins;
    ToastService.showNoticeToast("Podcaster 刪除了公告");
  }

  Future<void> handleLeaveRoom(WsMessageDto message) async {
    LiveRoomMemberDto member = LiveRoomMemberDto.fromJsonString(message.content);
    ToastService.showNoticeToast("${member.nickname} 離開房間了！");
    roomActionStream.add(RoomActionDto(action: RoomAction.leave, params: [member.userId]));

    final onMicMembers = ref.read(onMicMembersProvider);
    final updatedMembers = onMicMembers
        .where((m) => m.userId != member.userId)
        .toList();

    ref.watch(onMicMembersProvider.notifier).state = updatedMembers;

    return;
  }

  void _autoRejoin() {
    final userId = _userId;
    if (userId == null) return;
    Map<String, dynamic> data = {
      "cmd": "rejoinRoom",
      "from": userId,
      "storyId": _storyId,
      "roomId": roomId,
      "content": _clientType
    };
    wsService.sendJson(data);
  }

  Future<void> sendJoinRoomCmd(String userId, String storyId, String roomId) async {
    this.roomId = roomId;
    _userId = userId;
    _storyId = storyId;
    Map<String, dynamic> data = {
      "cmd": "joinRoom",
      "from": userId,
      "roomId": roomId
    };
    wsService.sendJson(data);
  }

  Future<void> sendSeekPosition(Duration position) async {
    if(!enteredRoom) {
      return;
    }
    int milliSec = position.inMilliseconds;
    Map<String, dynamic> data = {
      "cmd": "seekPosition",
      "content": milliSec.toString()
    };
    wsService.sendJson(data);
  }

  Future<void> sendAcceptInviteMic() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "acceptInviteMic",
      "roomId": roomId,
      "from": UserPrefs.getUserInfo()!.userId,
      "to": ref.read(roomInfoProvider)!.hostId
    };
    wsService.sendJson(data);
  }

  Future<void> sendChat(String content, {String? stickerUrl, int? donateAmount}) async {
    if(!enteredRoom) {
      return;
    }
    List<String> params = [];
    params.add(stickerUrl == null? "text" : "sticker");
    if(stickerUrl != null) {
      params.add(stickerUrl);
      params.add(donateAmount.toString());
    }
    Map<String, dynamic> data = {
      "cmd": "sendChat",
      "from": _userId,
      "content": content,
      "params": params
    };
    wsService.sendJson(data);
  }

  Future<void> sendThumb() async {
    if (!enteredRoom) return;

    wsService.sendJson({
      "cmd": "sendThumb",
      "from": _userId,
    });
  }

  Future<void> sendHandUp() async {
    if (!enteredRoom) return;

    wsService.sendJson({
      "cmd": "handUp",
    });
  }

  Future<void> sendHandDown() async {
    if (!enteredRoom) return;

    wsService.sendJson({
      "cmd": "handDown",
    });
  }

  Future<void> sendRevokeMic(String to) async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "revokeMic",
      "roomId": roomId,
      "to": to
    };
    wsService.sendJson(data);
  }

  Future<void> sendGetPlayer() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "getRoomPlayer",
    };
    wsService.sendJson(data);
  }

  Future<void> sendLeaveRoom() async {
    Map<String, dynamic> data = {
      "cmd": "leaveRoom"
    };
    wsService.sendJson(data);
  }

  void dispose() {
    sendLeaveRoom();
    _sub?.cancel();
    _sub = null;
    _connSub?.cancel();
    _connSub = null;
    _updatePlayerSyncTimer?.cancel();
    _updatePlayerSyncTimer = null;
    wsService.close();
    wsService.dispose();
  }
}