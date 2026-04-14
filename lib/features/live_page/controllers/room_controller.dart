import 'dart:async';

import 'package:actpod_web/api_manager/live_api_manager.dart';
import 'package:actpod_web/api_manager/live_dto/get_bulletins.dart';
import 'package:actpod_web/api_manager/live_dto/get_chats.dart';
import 'package:actpod_web/api_manager/live_dto/get_members.dart';
import 'package:actpod_web/api_manager/live_dto/get_player.dart';
import 'package:actpod_web/api_manager/live_dto/get_room_info.dart';
import 'package:actpod_web/api_manager/live_dto/get_stickers.dart';
import 'package:actpod_web/api_manager/live_dto/get_token.dart';
import 'package:actpod_web/features/live_page/dto/check_room.dart';
import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:actpod_web/features/live_page/dto/room_action.dart';
import 'package:actpod_web/features/live_page/dto/ws_message.dart';
import 'package:actpod_web/features/live_page/services/play_service.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/livekit_service.dart';
import 'package:actpod_web/services/permission_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:livekit_client/livekit_client.dart';

import '../providers/room.dart';

class RoomController {
  WidgetRef ref;
  LiveKitService liveKitService = LiveKitService();
  final StreamController<RoomActionDto> roomActionStream;
  final StreamController<MicPermissionAction>? micPermissionStream;
  final StreamController<LiveKitCmd>? livekitStream;
  final PlayService playService;
  String? _roomId;
  StreamSubscription<RoomActionDto>? _roomActionSub;
  StreamSubscription<MicPermissionAction>? _micPermissionSub;
  StreamSubscription<LiveKitCmd>? _livekitSub;
  StreamSubscription<ConnectionState>? _connectionSub;
  StreamSubscription<Map<String, bool>>? _speakingMapSub;
  final AudioPlayer _backgroundAudioPlayer = AudioPlayer();
  bool _alreadyFirstSetBackgroundVolume = false;

  RoomController(this.ref, this.roomActionStream, this.micPermissionStream, this.livekitStream, this.playService);

  Future<void> initRoomStreamController({required String? roomId}) async {
    _roomId = roomId;
    _roomActionSub?.cancel();
    _roomActionSub = null;
    _roomActionSub = roomActionStream.stream.listen((roomAction) async {
      if(roomAction.action == RoomAction.open) {
        _roomId = roomAction.params![0];
        checkRoomInfo(_roomId!);
        GetRoomChatsRes chatsRes = await liveApiManager.getRoomChats(_roomId!);
        if(chatsRes.code != "0000") {
          return;
        }
        ref.watch(chatMessagesProvider.notifier).state = chatsRes.chats;
      } else if(roomAction.action == RoomAction.playBackgroundMusic) {
        playBackgroundAudio(roomAction.params![0], double.parse(roomAction.params![1]));
      } else if(roomAction.action == RoomAction.stopBackgroundMusic) {
        pauseBackgroundAudio();
      }
    });

    _micPermissionSub?.cancel();
    _micPermissionSub = null;
    _micPermissionSub = micPermissionStream?.stream.listen((permission) async {
      if(permission == MicPermissionAction.granted) {
        startTalking();
      } else if(permission == MicPermissionAction.revoke) {
        stopTalking();
      }
    });

    _livekitSub?.cancel();
    _livekitSub = null;
    _livekitSub = livekitStream?.stream.listen((cmd) async {
      if(cmd.action == LiveKitAction.start) {
        String userId = UserPrefs.getUserInfo()!.userId;
        playService.pauseAudio();
        pauseBackgroundAudio();
        connectToLivekit(_roomId!, userId);
        ref.watch(interactiveRoomModeProvider.notifier).state = InteractiveRoomMode.active;
      } else if(cmd.action == LiveKitAction.stop) {
        liveKitService.leave();
        ref.watch(onMicMembersProvider.notifier).state = [];
        ref.watch(interactiveRoomModeProvider.notifier).state = InteractiveRoomMode.inactive;
      }
    });

    _connectionSub?.cancel();
    _connectionSub = null;
    _connectionSub = liveKitService.connectionStateStream.listen((state) async {
      if (state == ConnectionState.connected) {
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
        if(_alreadyFirstSetBackgroundVolume) {
          return;
        }
        _alreadyFirstSetBackgroundVolume = true;
        GetRoomPlayerRes response = await liveApiManager.getRoomPlayer(_roomId!);
        if(response.code != "0000") {
          return;
        }
      } else if (state == ConnectionState.connecting) {
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
      } else if (state == ConnectionState.disconnected) {
        _alreadyFirstSetBackgroundVolume = false;
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
      }
    });
  }

  Future<void> getRoomInfo(String roomId) async {
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(roomInfoProvider.notifier).state = response.room;

    GetRoomMembersRes membersRes = await liveApiManager.getRoomMembers(roomId);
    if(membersRes.code != "0000") {
      return;
    }
    ref.watch(roomMembersProvider.notifier).state = membersRes.members;
  }

	Future<CheckRoomRes> checkRoomInfo(String roomId) async {
    if(ref.read(userInfoProvider) == null) {
      return CheckRoomRes.error;
    }
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if(response.code != "0000") {
      return CheckRoomRes.error;
    }
    ref.watch(roomInfoProvider.notifier).state = response.room;

    if(response.room.capacity - response.room.memberCount <= 1) {
      return CheckRoomRes.full;
    }

    GetRoomMembersRes membersRes = await liveApiManager.getRoomMembers(roomId);
    if(membersRes.code != "0000") {
      return CheckRoomRes.error;
    }
    final currentUserId = ref.read(userInfoProvider)?.userId;
    final exists = membersRes.members.any((member) => member.userId == currentUserId);
    if(exists) {
      return CheckRoomRes.duplicate;
    }
    return CheckRoomRes.ok;
  }

  Future<void> getStickers() async {
    GetRoomStickersRes response = await liveApiManager.getStickers();
    if(response.code != "0000") {
      return;
    }
    ref.watch(stickersProvider.notifier).state = response.stickers;
  }

  Future<void> playBackgroundAudio(String url, double volume) async {
    if(ref.watch(livekitConnectionStateProvider) == ConnectionState.connected) {
      liveKitService.setParticipantAudioVolume(identity: "bgm-bot-$_roomId", volume: volume);
      return;
    }

    if(url == "" || url.isEmpty) {
      _backgroundAudioPlayer.pause();
      return;
    }
    try {
      await _backgroundAudioPlayer.setUrl(url);
      await _backgroundAudioPlayer.setLoopMode(LoopMode.all);
      await _backgroundAudioPlayer.setVolume(volume);
      _backgroundAudioPlayer.play();
    } catch(e) {
      ToastService.showNoticeToast("無法播放");
    }
  }

  Future<void> pauseBackgroundAudio() async {
    _backgroundAudioPlayer.pause();
    return;
  }

  Future<void> connectToLivekit(String roomId, String userId) async {
    GetRoomTokenRes response = await liveApiManager.getRoomToken(roomId, userId);
    liveKitService.joinAsListener(url: response.wsUrl, token: response.token);
    await _speakingMapSub?.cancel();
    _speakingMapSub = null;
    _speakingMapSub = liveKitService.speakingMapStream.listen((map) {
      List<LiveRoomMemberDto> onMicMembers = ref.read(onMicMembersProvider);
      for (final entry in map.entries) {
        for(final member in onMicMembers) {
          if(member.userId == entry.key) {
            member.isSpeaking = entry.value;
          }
        }
      }
      ref.watch(onMicMembersProvider.notifier).state = [...onMicMembers];
    });
  }

  Future<void> startTalking() async {
    if(ref.watch(livekitConnectionStateProvider) != ConnectionState.connected) {
      return;
    }
    if(await PermissionService.checkMicPermission()) {
      liveKitService.startTalking();
      ref.watch(onMicProvider.notifier).state = true;
    }
  }

  Future<void> stopTalking() async {
    liveKitService.stopTalking();
    ref.watch(onMicProvider.notifier).state = false;
  }

  Future<void> getBulletins(String? roomId) async {
    if(roomId == null) {
      return;
    }
    GetRoomBulletins getRoomBulletins = await liveApiManager.getRoomBulletins(roomId);
    if(getRoomBulletins.code != "0000") {
      return;
    }
    ref.watch(bulletinsProvider.notifier).state = getRoomBulletins.bulletins;
  }

  void dispose() {
    _backgroundAudioPlayer.dispose();
    liveKitService.leave();
    _roomActionSub?.cancel();
    _roomActionSub = null;
    _speakingMapSub?.cancel();
    _speakingMapSub = null;
    _micPermissionSub?.cancel();
    _micPermissionSub = null;
    _livekitSub?.cancel();
    _livekitSub = null;
    _connectionSub?.cancel();
    _connectionSub = null;
  }
}