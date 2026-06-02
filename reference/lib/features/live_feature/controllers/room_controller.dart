import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/create_background_music.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/create_room_bulletin.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/delete_room_bulletin.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_bulletins.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_info.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_members.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_player.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_token.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_stickers.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_user_background_music.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/update_room_bulletin.dart';
import 'package:quick_share_app/apiManagers/live_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/features/live_feature/dto/check_room_res.dart';
import 'package:quick_share_app/features/live_feature/dto/ws_message_dto.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/services/livekit_service.dart';
import 'package:quick_share_app/services/permission_service.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/live_api_dto/get_room_chats.dart';
import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../dto/live_room_member_dto.dart';
import '../../../services/player_service.dart';
import '../../../services/remote_config_service.dart';
import '../dto/room_action_dto.dart';

class RoomController {
  WidgetRef ref;
  LiveKitService liveKitService = LiveKitService();
  final StreamController<RoomActionDto> roomActionStream;
  final StreamController<MicPermissionAction>? micPermissionStream;
  final StreamController<LiveKitCmd>? livekitStream;
  StreamSubscription<Map<String, bool>>? _speakingMapSub;
  StreamSubscription<RoomActionDto>? _roomActionSub;
  StreamSubscription<MicPermissionAction>? _micPermissionSub;
  StreamSubscription<LiveKitCmd>? _livekitSub;
  StreamSubscription<ConnectionState>? _connectionSub;
  String? _roomId;

  RoomController(this.ref, this.roomActionStream, this.micPermissionStream,
      this.livekitStream);

  Future<void> initializeAudioSettings() async {
    if (Platform.isAndroid) {
      await webrtc.WebRTC.initialize(options: {
        'androidAudioConfiguration':
            webrtc.AndroidAudioConfiguration.media.toMap()
      });
      webrtc.Helper.setAndroidAudioConfiguration(
          webrtc.AndroidAudioConfiguration.media);
    }
  }

  Future<void> getStickers() async {
    GetRoomStickersRes response = await liveApiManager.getStickers();
    if (response.code != "0000") {
      return;
    }
    ref.watch(stickersProvider.notifier).state = response.stickers;
  }

  Future<void> initRoomStreamController(
      {required bool isHost, String? roomId}) async {
    initializeAudioSettings();
    if (!isHost) {
      _roomId = roomId;
    }
    await _roomActionSub?.cancel();
    _roomActionSub = null;
    _roomActionSub = roomActionStream.stream.listen((roomAction) async {
      if (roomAction.action == RoomAction.open) {
        _roomId = roomAction.params![0];
        checkRoomInfo(_roomId!, isHost: isHost);
        GetRoomChatsRes chatsRes = await liveApiManager.getRoomChats(_roomId!);
        if (chatsRes.code != "0000") {
          return;
        }
        ref.watch(chatMessagesProvider.notifier).state = chatsRes.chats;
      } else if (roomAction.action == RoomAction.playBackgroundMusic) {
        playBackgroundAudio(roomAction.params![0]);
        ref.watch(playingBackgroundMusicUrlProvider.notifier).state =
            roomAction.params![0];
      } else if (roomAction.action == RoomAction.stopBackgroundMusic) {
        pauseBackgroundAudio();
      }
    });

    _micPermissionSub?.cancel();
    _micPermissionSub = null;
    _micPermissionSub = micPermissionStream?.stream.listen((permission) async {
      if (permission == MicPermissionAction.granted) {
        startTalking();
      } else if (permission == MicPermissionAction.revoke) {
        stopTalking();
      }
    });

    await _livekitSub?.cancel();
    _livekitSub = null;
    _livekitSub = livekitStream?.stream.listen((cmd) async {
      if (cmd.action == LiveKitAction.start) {
        String userId = UserService.getUserInfo()!.userId;
        await playBackgroundAudio(
            RemoteConfigService.instance.liveRoomSilenceMusic);
        await Future.delayed(const Duration(milliseconds: 500));
        await connectToLivekit(_roomId!, userId);
        ref.watch(interactiveRoomModeProvider.notifier).state =
            InteractiveRoomMode.active;
      } else if (cmd.action == LiveKitAction.stop) {
        await liveKitService.leave();
        ref.watch(onMicMembersProvider.notifier).state = [];
        ref.watch(interactiveRoomModeProvider.notifier).state =
            InteractiveRoomMode.inactive;
        await playBackgroundAudio(
            RemoteConfigService.instance.liveRoomDefaultMusic);
      }
    });

    _connectionSub?.cancel();
    _connectionSub = null;
    _connectionSub = liveKitService.connectionStateStream.listen((state) async {
      if (state == ConnectionState.connected) {
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
        GetRoomPlayerRes response =
            await liveApiManager.getRoomPlayer(_roomId!);
        if (response.code != "0000") {
          return;
        }
      } else if (state == ConnectionState.connecting) {
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
      } else if (state == ConnectionState.disconnected) {
        ref.watch(livekitConnectionStateProvider.notifier).state = state;
      }
    });
  }

  Future<void> getBackgroundMusics() async {
    GetUserBackgroundMusic response =
        await liveApiManager.getBackgroundMusics();
    if (response.code != "0000") {
      return;
    }
    ref.watch(backgroundMusicsProvider.notifier).state =
        response.backgroundMusics;
  }

  Future<CheckRoomRes> checkRoomInfo(String roomId,
      {required bool isHost}) async {
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if (response.code != "0000") {
      return CheckRoomRes.error;
    }
    ref.watch(roomInfoProvider.notifier).state = response.room;

    if (response.room.capacity - response.room.memberCount <= 1) {
      return CheckRoomRes.full;
    }

    if (!isHost) {
      GetRoomMembersRes membersRes =
          await liveApiManager.getRoomMembers(roomId);
      if (membersRes.code != "0000") {
        return CheckRoomRes.error;
      }
      final currentUserId = UserService.getUserInfo()!.userId;
      final exists =
          membersRes.members.any((member) => member.userId == currentUserId);
      if (exists) {
        return CheckRoomRes.duplicate;
      }
    }
    return CheckRoomRes.ok;
  }

  Future<BackRoomRes> backRoom(String roomId, {required bool isHost}) async {
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if (response.code != "0000") {
      return BackRoomRes.error;
    }

    if (!isHost) {
      GetRoomMembersRes membersRes =
          await liveApiManager.getRoomMembers(roomId);
      if (membersRes.code != "0000") {
        return BackRoomRes.error;
      }
      final currentUserId = UserService.getUserInfo()!.userId;
      final exists =
          membersRes.members.any((member) => member.userId == currentUserId);
      if (!exists) {
        return BackRoomRes.left;
      }
    }
    return BackRoomRes.ok;
  }

  Future<void> connectToLivekit(String roomId, String userId) async {
    GetRoomTokenRes response =
        await liveApiManager.getRoomToken(roomId, userId);
    await liveKitService.joinAsListener(
        url: response.wsUrl, token: response.token);
    await _speakingMapSub?.cancel();
    _speakingMapSub = null;
    _speakingMapSub = liveKitService.speakingMapStream.listen((map) {
      List<LiveRoomMemberDto> onMicMembers = ref.read(onMicMembersProvider);
      for (final entry in map.entries) {
        for (final member in onMicMembers) {
          if (member.userId == entry.key) {
            member.isSpeaking = entry.value;
          }
        }
      }
      ref.watch(onMicMembersProvider.notifier).state = [...onMicMembers];
    });
  }

  Future<void> startTalking() async {
    if (ref.watch(livekitConnectionStateProvider) !=
        ConnectionState.connected) {
      return;
    }
    if (await PermissionService.checkMicPermission()) {
      await liveKitService.startTalking();
      ref.watch(onMicProvider.notifier).state = true;
    }
  }

  Future<void> stopTalking() async {
    await liveKitService.stopTalking();
    ref.watch(onMicProvider.notifier).state = false;
    if (ref.read(interactiveRoomModeProvider) == InteractiveRoomMode.active &&
        ref.read(podcastPlayerStatusProvider) == PodcastPlayerStatus.paused) {
      await playBackgroundAudio(
          RemoteConfigService.instance.liveRoomSilenceMusic);
    }
  }

  Future<void> getBulletins(String? roomId) async {
    if (roomId == null) {
      return;
    }
    GetRoomBulletins getRoomBulletins =
        await liveApiManager.getRoomBulletins(roomId);
    if (getRoomBulletins.code != "0000") {
      return;
    }
    ref.watch(bulletinsProvider.notifier).state = getRoomBulletins.bulletins;
  }

  Future<void> createBulletin(
    String? roomId,
    String title,
    String content,
    List<File> files,
  ) async {
    if (roomId == null) {
      return;
    }

    try {
      // Upload all files concurrently
      final uploadResults = await Future.wait(
        files.map((file) => uploadApiManager.uploadBulletinImage(file)),
      );

      // Check if any upload failed
      final hasUploadFailed = uploadResults.any((res) => res.code != "0000");
      if (hasUploadFailed) {
        ToastService.showNoticeToast("圖片上傳失敗");
        return;
      }

      // Collect uploaded public URLs
      final imageUrls = uploadResults
          .map((res) => res.data?.publicUrl)
          .whereType<String>()
          .toList();

      final createResponse = await liveApiManager.createRoomBulletin(
        roomId,
        title,
        content,
        imageUrls, // changed from imageUrl to imageUrls
      );

      if (createResponse.code != "0000") {
        ToastService.showNoticeToast("建立失敗");
        return;
      }
    } catch (e) {
      ToastService.showNoticeToast("建立失敗");
    }
  }

  Future<void> updateBulletin(
    String bulletinId,
    String title,
    String content,
    List<String> oldImageUrls,
    List<File> fileList,
  ) async {
    try {
      List<String> finalImageUrls = List<String>.from(oldImageUrls);

      if (fileList.isNotEmpty) {
        final uploadResults = await Future.wait(
          fileList.map((file) => uploadApiManager.uploadBulletinImage(file)),
        );

        final hasUploadFailed = uploadResults.any((res) => res.code != "0000");

        if (hasUploadFailed) {
          ToastService.showNoticeToast("圖片上傳失敗");
          return;
        }

        final newImageUrls = uploadResults
            .map((res) => res.data?.publicUrl)
            .whereType<String>()
            .where((url) => url.trim().isNotEmpty)
            .toList();

        finalImageUrls = [
          ...newImageUrls,
        ];
      }

      final updateResponse = await liveApiManager.updateRoomBulletin(
        bulletinId,
        title,
        content,
        finalImageUrls,
      );

      if (updateResponse.code != "0000") {
        ToastService.showNoticeToast("更新失敗");
        return;
      }
    } catch (e) {
      ToastService.showNoticeToast("更新失敗");
    }
  }

  Future<void> deleteBulletin(String bulletinId) async {
    DeleteRoomBulletinRes deleteResponse =
        await liveApiManager.deleteRoomBulletin(bulletinId);
    if (deleteResponse.code != "0000") {
      ToastService.showNoticeToast("刪除失敗");
      return;
    }
    ToastService.showSuccessToast("刪除成功");
  }

  Future<void> playBackgroundAudio(String url) async {
    if (url == "" || url.isEmpty) {
      actPodAudioHandler?.pause();
      return;
    }
    try {
      actPodAudioHandler?.setSpeed(1.0);
      GetOneStoryResItem storyInfo = ref.read(storyInfoProvider)!;
      ref.watch(podcastPlayerStatusProvider.notifier).state =
          PodcastPlayerStatus.paused;
      ref.watch(playingBackgroundMusicUrlProvider.notifier).state = url;
      playerService.changeMusicByUrl(
          id: storyInfo.storyUrl,
          title: "${storyInfo.storyName}(暫停)",
          url: url,
          album: storyInfo.nickname,
          artist: storyInfo.storyDescription,
          artUrl: storyInfo.storyImageUrl,
          repeatMode: AudioServiceRepeatMode.all);
    } catch (e) {
      print(e);
    }
  }

  Future<void> pauseBackgroundAudio() async {
    // _backgroundAudioPlayer.pause();
    return;
  }

  Future<void> createBackgroundMusic(File audioFile, String name) async {
    String? fixedFilePath = await AudioUtils.fixMusicToTargetMeanVolume(
        audioFile.path,
        targetMeanVolumeDb: -36.0);
    if (fixedFilePath == null) {
      return;
    }

    String? oggPath = await AudioUtils.convertMp3ToOggOpus(fixedFilePath);
    if (oggPath == null) {
      return;
    }

    GetUploadUrlRes mp3Response =
        await uploadApiManager.uploadBackgroundMp3Audio(File(fixedFilePath));
    if (mp3Response.code != "0000") {
      ToastService.showNoticeToast("建立失敗");
      return;
    }

    GetUploadUrlRes oggResponse =
        await uploadApiManager.uploadBackgroundOggAudio(File(oggPath));
    if (oggResponse.code != "0000") {
      ToastService.showNoticeToast("建立失敗");
      return;
    }

    CreateBackgroundMusicRes createRes =
        await liveApiManager.createBackgroundMusic(
            name, mp3Response.data!.publicUrl, oggResponse.data!.publicUrl);
    if (createRes.code != "0000") {
      ToastService.showNoticeToast("建立失敗");
      return;
    }

    await getBackgroundMusics();
    File(fixedFilePath).delete();
    File(oggPath).delete();
    ToastService.showSuccessToast("建立成功");
  }

  void dispose() {
    // _backgroundAudioPlayer.dispose();
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
