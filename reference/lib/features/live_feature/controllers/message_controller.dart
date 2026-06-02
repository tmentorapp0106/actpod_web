import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/live_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/features/live_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/live_feature/dto/chat_message_dto.dart';
import 'package:quick_share_app/features/live_feature/dto/mic_action_dto.dart';
import 'package:quick_share_app/features/live_feature/dto/ws_message_dto.dart';
import 'package:quick_share_app/features/live_feature/services/play_service.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/player_service.dart';
import 'package:quick_share_app/services/remote_config_service.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../apiManagers/live_api_dto/get_livekit_status.dart';
import '../../../apiManagers/live_api_dto/get_room_bulletins.dart';
import '../../../apiManagers/live_api_dto/get_room_player.dart';
import '../../../apiManagers/purchase_api_dto/get_user_purses_res.dart';
import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../dto/live_room_member_dto.dart';
import '../../../services/ws_service.dart';
import '../dto/room_action_dto.dart';
import '../providers.dart';

class MessageController {
  WidgetRef ref;
  WsService? wsService;
  StreamController<RoomActionDto> roomActionStream;
  StreamController<MicPermissionAction>? micPermissionStream;
  StreamController<void> thumbReactionStream;
  StreamController<LiveKitCmd>? livekitStream;
  StreamController<MemberActionDto>? micActionStream;
  String? roomId;
  String? _userId;
  String? _storyId;
  String? _clientType;
  Timer? _updatePlayerSyncTimer;
  bool enteredRoom = false;
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  StreamSubscription<bool>? _connSub;
  final int maxAutoRejoin = 10;
  int autoRejoinCount = 0;
  bool roomClosed = false;

  MessageController(this.ref, this.wsService, this.roomActionStream, this.micPermissionStream, this.thumbReactionStream, this.livekitStream, this.micActionStream);

  Future<void> initWebsocket(String userId) async {
    if(wsService == null) {
      wsService = WsService(wsBaseUrl: dotenv.env["WS_SERVER_URL"]?? "");
    }
    await wsService?.connect(path: "/live/ws?userId=$userId");

    _connSub = wsService?.connected?.listen((isConnected) {
      if (!isConnected) return;
      _autoRejoin();
    });

    _wsSub = wsService?.messages?.listen((msg) async {
        WsMessageDto message  = WsMessageDto.fromJson(msg);
        switch(message.cmd){
        case "roomReady":
          if (message.roomId.isNotEmpty) {
            handleOpenRoomSuccess(message);
          }
          return;
        case "accessRoom":
            LiveRoomMemberDto member = LiveRoomMemberDto.fromJsonString(message.content);
            ToastService.showSuccessToast("${member.nickname} 加入房間了！");
            roomActionStream.add(RoomActionDto(action: RoomAction.join, member: member));
            return;
        case "leaveRoom":
          handleLeaveRoom(message);
          return;
        case "hostLeave":
          handleHostLeave();
          return;
        case "hostReturn":
          handleHostReturn();
          return;

        case "playPodcast":
          handlePlayPodcast(message);
        return;
        case "pausePodcast":
          handlePausePodcast();
        return;
        case "seekPosition":
          handleSeekPosition(message.content);
        return;
        case "joinRoomSuccess":
          handleJoinRoomSuccess();
          return;
        case "initRoomPlayer":
          handleInitRoomPlayer(message);
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
          handleCloseRoom();
          return;
        case "kickOutRoom":
          handleKickOut();
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

  Future<void> handleOpenRoomSuccess(WsMessageDto msg) async {
    enteredRoom = true;
    roomId = msg.roomId;
    roomActionStream.add(RoomActionDto(action: RoomAction.open, params: [msg.roomId]));

    if(msg.params.isNotEmpty && msg.params[0] == "rejoin") {
      GetRoomPlayerRes response = await liveApiManager.getRoomPlayer(msg.roomId);
      if(response.code != "0000") {
        ToastService.showNoticeToast("rejoin failed");
        await actPodAudioHandler!.wsService.close();
        router.go("/");
        return;
      }
      ref.watch(currentPositionProvider.notifier).state = Duration(milliseconds: response.player.position);
    }

    if(_clientType == "host") {
      _startUpdatePlayerSyncTimer();
    }

    int maxTryTimes = 10;
    int tryTimes = 0;
    while(ref.read(storyInfoProvider) == null) {
      tryTimes++;
      if(tryTimes >= maxTryTimes) return;
      await Future.delayed(Duration(milliseconds: 500));
    }
    sendPausePodcast();
  }

  Future<void> handleJoinRoomSuccess() async {
    if(roomId != null) {
      enteredRoom = true;
      roomActionStream.add(RoomActionDto(action: RoomAction.open, params: [roomId!]));
      sendInitPlayer(ref.read(roomInfoProvider)!.hostId);
    }
  }

  Future<void> handleInitRoomPlayer(WsMessageDto msg) async {
    if(_clientType == "host") {
      sendInitPlayer(msg.from);
    } else {
      GetLivekitStatusRes livekitStatusRes = await liveApiManager.getLivekitStatus(roomId!);
      if(livekitStatusRes.code == "0000") {
        if(livekitStream != null) {
          if(livekitStatusRes.status.started) {
            livekitStream?.add(LiveKitCmd(LiveKitAction.start, ""));
            List<String> userIdList = livekitStatusRes.status.onMicMembers;
            List<LiveRoomMemberDto> roomMembers = ref.read(roomMembersProvider);

            List<LiveRoomMemberDto> onMicList = [];
            for (final userId in userIdList) {
              final matches = roomMembers.where((m) => m.userId == userId);
              if (matches.isNotEmpty) {
                onMicList.add(matches.first);
              }
            }
            ref.watch(onMicMembersProvider.notifier).state = onMicList;
          }
        }
        return;
      }
      GetOneStoryResItem storyInfo = ref.read(storyInfoProvider)!;
      if (msg.params[0] == "playing") {
        ref.watch(currentPositionProvider.notifier).state = Duration(milliseconds: int.parse(msg.params[1]));
        playerService.changeMusicByUrl(
          id: storyInfo.storyId,
          title: storyInfo.storyName,
          url: storyInfo.storyUrl,
          album: storyInfo.nickname,
          artist: storyInfo.storyDescription,
          artUrl: storyInfo.storyImageUrl,
          repeatMode: AudioServiceRepeatMode.all,
          initPosition: Duration(milliseconds: int.parse(msg.params[1]))
        );
      } else {
        ref.watch(currentPositionProvider.notifier).state = Duration(milliseconds: int.parse(msg.params[1]));
        playerService.changeMusicByUrl(
          id: storyInfo.storyUrl,
          title: "${storyInfo.storyName}(暫停)",
          url: msg.params[2] == ""? RemoteConfigService.instance.liveRoomDefaultMusic : msg.params[2],
          album: storyInfo.nickname,
          artist: storyInfo.storyDescription,
          artUrl: storyInfo.storyImageUrl,
          repeatMode: AudioServiceRepeatMode.all
        );
      }
    }
  }

  Future<void> handleStartLiveKit(String roomId) async {
    livekitStream?.add(LiveKitCmd(LiveKitAction.start, ""));
    }

  Future<void> handleCloseRoom() async {
    roomClosed = true;
    actPodAudioHandler?.pause();
    await wsService?.close();
    await wsService?.dispose();
    wsService = null;
    ToastService.showNoticeToast("Podcaster 關閉了房間");
    router.go("/");
  }

  Future<void> handleKickOut() async {
    actPodAudioHandler?.pause();
    await wsService?.close();
    await wsService?.dispose();
    wsService = null;
    ToastService.showNoticeToast("您被踢出房間");
    router.go("/");
  }

  Future<void> handleStopLiveKit(String roomId) async {
    livekitStream?.add(LiveKitCmd(LiveKitAction.stop, ""));
    }

  Future<void> handleUpdateMic(String userIdListStr) async {
    final userIdList = (jsonDecode(userIdListStr) as List)
        .map((e) => e.toString())
        .toList();

    final roomMembers = ref.read(roomMembersProvider);
    final previousOnMicList = ref.read(onMicMembersProvider);

    final onMicList = <LiveRoomMemberDto>[];

    for (final userId in userIdList) {
      LiveRoomMemberDto? match;

      for (final member in roomMembers) {
        if (member.userId == userId) {
          match = member;
          break;
        }
      }

      if (match != null) {
        onMicList.add(match);
      }
    }

    final previousUserIds = previousOnMicList.map((m) => m.userId).toSet();
    final newUserIds = onMicList.map((m) => m.userId).toSet();

    final addedUserIds = newUserIds.difference(previousUserIds);


    final didAddMe = addedUserIds.contains(_userId);

    if (didAddMe) {
      // I was newly added to mic
      micPermissionStream?.add(MicPermissionAction.granted);
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

  Future<void> handlePlayPodcast(WsMessageDto message) async {
    int position = int.parse(message.params[0]);

    const maxRetries = 5;
    int retryCount = 0;

    while (ref.read(livekitConnectionStateProvider) == livekit_client.ConnectionState.connected &&
        retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 300));
      retryCount++;
    }

    GetOneStoryResItem storyInfo = ref.read(storyInfoProvider)!;
    playerService.changeMusicByUrl(
        id: storyInfo.storyId,
        title: storyInfo.storyName,
        url: storyInfo.storyUrl,
        album: storyInfo.nickname,
        artist: storyInfo.storyDescription,
        artUrl: storyInfo.storyImageUrl,
        repeatMode: AudioServiceRepeatMode.all,
        initPosition: Duration(milliseconds: position)
    );
  }

  Future<void> handlePausePodcast() async {
    roomActionStream.add(RoomActionDto(action: RoomAction.playBackgroundMusic, params: [RemoteConfigService.instance.liveRoomDefaultMusic]));
  }

  Future<void> handleSeekPosition(String positionStr) async {
    final position = int.tryParse(positionStr);
    await actPodAudioHandler?.seek(Duration(milliseconds: position?? 0));
  }

  Future<void> handlePlayer(String playerStatus, int position, String? backgroundMusicUrl) async {
    if(ref.read(podcastPlayerStatusProvider) == PodcastPlayerStatus.playing) {
      final currentPosition = actPodAudioHandler?.getCurrentDuration();
      final currentSpeed = actPodAudioHandler?.getSpeed();
      final differ = (currentPosition?.inMilliseconds?? position) - position;
      if(differ < -5000) {
        actPodAudioHandler?.seek(Duration(milliseconds: position));
      } else if(differ < -1000) {
        if(currentSpeed != 1.1) {
          actPodAudioHandler?.setSpeed(1.1);
        }
      } else if(differ < -3000) {
        if(currentSpeed != 1.2) {
          actPodAudioHandler?.setSpeed(1.2);
        }
      } else if(differ > 1000) {
        if(currentSpeed != 0.9) {
          actPodAudioHandler?.setSpeed(0.9);
        }
      } else if(differ > 3000) {
        if(currentSpeed != 0.8) {
          actPodAudioHandler?.setSpeed(0.8);
        }
      } else if(differ > 5000) {
        actPodAudioHandler?.seek(Duration(milliseconds: position));
      } else {
        if(currentSpeed != 1.0) {
          actPodAudioHandler?.setSpeed(1.0);
        }
      }
    }
  }

  Future<void> handleLeaveRoom(WsMessageDto message) async {
    LiveRoomMemberDto member = LiveRoomMemberDto.fromJsonString(message.content);
    roomActionStream.add(RoomActionDto(action: RoomAction.leave, params: [member.userId]));

    final onMicMembers = ref.read(onMicMembersProvider);
    final updatedMembers = onMicMembers
        .where((m) => m.userId != member.userId)
        .toList();

    ref.watch(onMicMembersProvider.notifier).state = updatedMembers;

    return;
  }

  Future<void> handleHostLeave() async {
    ref.watch(isHostedProvider.notifier).state = false;
  }

  Future<void> handleHostReturn() async {
    ref.watch(isHostedProvider.notifier).state = true;
  }

  Future<void> sendOpenRoomCmd(String roomId, String userId, String storyId, String title, String roomType, int capacity, bool notifyFans, int notyetOwnedPrice, int alreadyOwnedPrice) async {
    _userId = userId;
    _clientType = "host";
    _storyId = storyId;
    List<String> roomParams = [roomType, capacity.toString(), notifyFans? "true" : "false", notyetOwnedPrice.toString(), alreadyOwnedPrice.toString()];
    Map<String, dynamic> data = {
      "cmd": "openRoom",
      "from": userId,
      "content": title,
      "storyId": storyId,
      "roomId": roomId,
      "params": roomParams
    };
    wsService?.sendJson(data);
  }

  Future<void> sendJoinRoomCmd(String userId, String storyId, String roomId) async {
    this.roomId = roomId;
    _userId = userId;
    _storyId = storyId;
    _clientType = "audience";
    Map<String, dynamic> data = {
      "cmd": "joinRoom",
      "from": userId,
      "roomId": roomId
    };
    wsService?.sendJson(data);
  }

  Future<void> sendInitPlayer(String to) async {
    Map<String, dynamic> data;
    if(_clientType == "host") {
      data = {
        "cmd": "initRoomPlayer",
        "to": to,
        "params": [
          ref.read(podcastPlayerStatusProvider) == PodcastPlayerStatus.playing? "playing" : "paused",
          ref.read(currentPositionProvider).inMilliseconds.toString(),
          ref.read(playingBackgroundMusicUrlProvider)
        ]
      };
    } else {
      data = {
        "cmd": "initRoomPlayer",
        "from": UserService.getUserInfo()!.userId,
        "to": to,
        "roomId": roomId,
      };
    }
    wsService?.sendJson(data);
  }

  Future<void> sendGetPlayer() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "getRoomPlayer",
    };
    wsService?.sendJson(data);
  }

  Future<void> sendPlayPodcast() async {
    if(!enteredRoom) {
      return;
    }
    List<String> params = [];
    params.add(ref.read(currentPositionProvider).inMilliseconds.toString());
    Map<String, dynamic> data = {
      "cmd": "playPodcast",
      "params": params
    };
    wsService?.sendJson(data);
  }

  Future<void> sendPausePodcast() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "pausePodcast",
    };
    wsService?.sendJson(data);
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
    wsService?.sendJson(data);
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
    wsService?.sendJson(data);
  }

  Future<void> sendCreatedBulletin() async {
    if(!enteredRoom) {
      return;
    }
    if (_clientType != "host") return;

    Map<String, dynamic> data = {
      "cmd": "createdBulletin",
    };
    wsService?.sendJson(data);
  }

  Future<void> sendUpdatedBulletin() async {
    if(!enteredRoom) {
      return;
    }
    if (_clientType != "host") return;

    Map<String, dynamic> data = {
      "cmd": "updatedBulletin",
    };
    wsService?.sendJson(data);
  }

  Future<void> sendDeletedBulletin() async {
    if(!enteredRoom) {
      return;
    }
    if (_clientType != "host") return;

    Map<String, dynamic> data = {
      "cmd": "deletedBulletin",
    };
    wsService?.sendJson(data);
  }

  Future<void> sendThumb() async {
    if (!enteredRoom) return;

    wsService?.sendJson({
      "cmd": "sendThumb",
      "from": _userId,
    });
  }

  Future<void> sendHandUp() async {
    if (!enteredRoom) return;

    wsService?.sendJson({
      "cmd": "handUp",
    });
  }

  Future<void> sendHandDown() async {
    if (!enteredRoom) return;

    wsService?.sendJson({
      "cmd": "handDown",
    });
  }

  Future<void> sendInviteMic(String to) async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "inviteMic",
      "roomId": roomId,
      "to": to,
    };
    wsService?.sendJson(data);
  }

  Future<void> sendKickOutRoom(String to) async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "kickOutRoom",
      "roomId": roomId,
      "to": to,
    };
    wsService?.sendJson(data);
  }

  Future<void> sendAcceptInviteMic() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "acceptInviteMic",
      "roomId": roomId,
      "from": UserService.getUserInfo()!.userId,
      "to": ref.read(roomInfoProvider)!.hostId
    };
    wsService?.sendJson(data);
  }

  Future<void> sendRejectInviteMic() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "rejectInviteMic",
      "roomId": roomId,
      "from": UserService.getUserInfo()!.userId,
      "to": ref.read(roomInfoProvider)!.hostId
    };
    wsService?.sendJson(data);
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
    wsService?.sendJson(data);
  }

  Future<void> sendPlayBackgroundMusic(String backgroundMusicId) async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "playBackgroundMusic",
      "roomId": roomId,
      "params": [
        backgroundMusicId,
      ]
    };
    wsService?.sendJson(data);
  }

  Future<void> sendStopBackgroundMusic() async {
    if(!enteredRoom) {
      return;
    }
    Map<String, dynamic> data = {
      "cmd": "stopBackgroundMusic",
      "roomId": roomId,
    };
    wsService?.sendJson(data);
  }

  Future<void> sendCloseRoom() async {
    Map<String, dynamic> data = {
      "cmd": "closeRoom"
    };
    wsService?.sendJson(data);
  }

  Future<void> sendLeaveRoom() async {
    Map<String, dynamic> data = {
      "cmd": "leaveRoom"
    };
    wsService?.sendJson(data);
  }

  Future<void> sendUpdatePlayerCmd() async {
    if (!enteredRoom) return;
    if (_clientType != "host") return;

    final playerStatus = ref.read(podcastPlayerStatusProvider);
    final status = playerStatus == PodcastPlayerStatus.playing ? "playing" : "paused";
    final positionMs = actPodAudioHandler?.getCurrentDuration().inMilliseconds?? 0;

    Map<String, dynamic> data = {
      "cmd": "updateRoomPlayer",
      "params": [status, positionMs.toString()],
    };

    wsService?.sendJson(data);
  }

  Future<void> sendStartLiveKit() async {
    if (!enteredRoom) return;
    if (_clientType != "host") return;

    Map<String, dynamic> data = {
      "cmd": "startLiveKit",
    };

    wsService?.sendJson(data);
  }

  Future<void> sendStopLiveKit() async {
    if (!enteredRoom) return;
    if (_clientType != "host") return;

    Map<String, dynamic> data = {
      "cmd": "stopLiveKit",
    };

    wsService?.sendJson(data);
  }

  Future<void> sendAcceptMicInvitation() async {
    if (!enteredRoom) return;
    if (_clientType == "host") return;

    Map<String, dynamic> data = {
      "cmd": "stopLiveKit",
    };

    wsService?.sendJson(data);
  }

  Future<void> sendToBackground() async {
    if (!enteredRoom) return;

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    Map<String, dynamic> data = {
      "cmd": "toBackground",
      "params": [fcmToken],
    };

    wsService?.sendJson(data);
  }

  Future<void> sendToForeground() async {
    if (!enteredRoom) return;

    Map<String, dynamic> data = {
      "cmd": "toForeground",
    };

    wsService?.sendJson(data);
  }

  Future<void> sendRejoin() async {
    Map<String, dynamic> data = {
      "cmd": "rejoinRoom",
      "from": _userId,
      "storyId": _storyId,
      "roomId": roomId,
      "content": _clientType
    };
    wsService?.sendJson(data);
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

  void _autoRejoin() {
    if(autoRejoinCount > maxAutoRejoin) {
      ToastService.showNoticeToast("與直播房斷連，請重新進入");
      wsService?.close();
      wsService?.dispose();
      wsService = null;
      router.pop();
      return;
    }
    final userId = _userId;
    if (userId == null) return;
    Map<String, dynamic> data = {
      "cmd": "rejoinRoom",
      "from": userId,
      "storyId": _storyId,
      "roomId": roomId,
      "content": _clientType
    };
    wsService?.sendJson(data);
  }

  void _startUpdatePlayerSyncTimer() {
    // Usually only host should broadcast player state
    if (_clientType != "host") return;
    // Prevent duplicate timers
    _updatePlayerSyncTimer?.cancel();

    _updatePlayerSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Avoid sending if not in room / disconnected
      if (!enteredRoom || roomId == null) return;
      if (ref.read(podcastPlayerStatusProvider) != PodcastPlayerStatus.playing) return;
      sendUpdatePlayerCmd();
    });
  }

  Future<void> closeWs() async {
    await wsService?.close();
    wsService?.dispose();
    wsService = null;
  }

  void dispose() {
    if(_clientType == "host") {
      sendCloseRoom();
      sendStopLiveKit();
    } else {
      sendLeaveRoom();
    }
    _wsSub?.cancel();
    _wsSub = null;
    _connSub?.cancel();
    _connSub = null;
    _updatePlayerSyncTimer?.cancel();
    _updatePlayerSyncTimer = null;
  }
}