import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_interactive_content_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/interactive_content_dto.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/providers.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/services/play_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../dto/voice_message_dto.dart';
import '../../../providers.dart';
import '../../../services/toast_service.dart';

class PlayerController {
  WidgetRef _ref;
  VoiceMessageDto _voiceMessageDto;
  final PlayService _playService = PlayService(AudioPlayer());

  PlayerController(this._ref, this._voiceMessageDto);

  void dispose() {
    _playService.dispose();
  }

  Future<void> prepareAudio(String storyId, String voiceMessageId, String? preMessagePath, String? afterMessagePath, Function onSuccess) async {
    const Duration fade = Duration(milliseconds: 200);
    List<String> audioFilePathList = [];
    UserInfoDto userInfo = UserService.getUserInfo()!;

    if(preMessagePath != null && preMessagePath != "") {
      audioFilePathList.add(preMessagePath);
    }

    List<String> audioUrlList = [];
    audioUrlList.add(_voiceMessageDto.url);
    for(ResponseDto responseDto in _voiceMessageDto.responseList?? []) {
      audioUrlList.add(responseDto.url);
    }
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    List<Future<String?>> downloadTasks = audioUrlList.map((url) async {
      try {
        String localFilePath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.mp3';
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          File file = File(localFilePath);
          await file.writeAsBytes(response.bodyBytes);
          return localFilePath;
        } else {
          print("Failed to download: $url");
          return null;
        }
      } catch (e) {
        print("Error downloading $url: $e");
        return null;
      }
    }).toList();
    // Wait for all downloads to complete
    List<String> localFilePaths = (await Future.wait(downloadTasks))
        .whereType<String>() // Filter out failed downloads
        .toList();
    if (localFilePaths.isEmpty) {
      print("No files downloaded successfully.");
      return;
    }
    audioFilePathList.addAll(localFilePaths);

    if(afterMessagePath != null && afterMessagePath != "") {
      audioFilePathList.add(afterMessagePath);
    }

    AudioUtils.concatAudiosWithFadeSingleCommand(
      audioFilePathList,
      fade.inMilliseconds,
      (path) async {
        Duration? length = await AudioUtils.getAudioFileLength(path);
        _ref.watch(totalLengthProvider.notifier).state = length!;
        _ref.watch(concatedMessageFilePath.notifier).state = path;
        _playService.prepareFileAudio(path, onCursorChange, onComplete);
        _ref.watch(loadingProvider.notifier).state = false;
        onSuccess();
      },
      () {
        ToastService.showNoticeToast("concat failed");
        _ref.watch(concatedMessageFilePath.notifier).state = null;
        _ref.watch(loadingProvider.notifier).state = false;
      },
      (progress) {
        print("processing");
      }
    );
  }

  Future<void> onCursorChange(Duration duration) async {
    _ref.watch(playTimerProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {
    await _playService.seekPosition(0);
    _playService.pauseAudio();
    _ref.watch(playerStatusProvider.notifier).state = "paused";
  }

  Future<void> play() async {
    _ref.watch(playerStatusProvider.notifier).state = "playing";
    await _playService.playAudio();
  }

  Future<void> pause() async {
    await _playService.pauseAudio();
    _ref.watch(playerStatusProvider.notifier).state = "paused";
  }

  Future<void> seek(Duration duration) async {
    await _playService.seekPosition(duration.inMilliseconds);
  }
}