import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/apiManagers/transition_api_dto/get_transitions_res.dart';
import 'package:quick_share_app/apiManagers/transition_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/transition_api_dto/create_transition_res.dart';
import '../../../apiManagers/upload_api_dto/get_upload_url_res.dart';
import '../services/play_service.dart';


class TransitionController {
  final WidgetRef ref;
  final PlayService _playService = PlayService(AudioPlayer());

  TransitionController(this.ref);

  Future<void> getTransitionList() async {
    GetTransitionListRes response = await transitionApiManager.getTransitionList();
    if(response.code != "0000") {
      ref.watch(transitionListProvider.notifier).state = null;
      return;
    }
    ref.watch(transitionListProvider.notifier).state = response.transitionList;
  }

  Future<void> uploadTransition(File transitionFile, String name) async {
    Duration? duration = await AudioUtils.getAudioFileLength(transitionFile.path);
    if(duration == null) {
      ToastService.showNoticeToast("檔案讀取失敗");
      return;
    }
    GetUploadUrlRes uploadRes = await uploadApiManager.uploadTransition(transitionFile);
    if(uploadRes.code != "0000") {
      ToastService.showNoticeToast("檔案上傳失敗");
      return;
    }
    CreateTransitionRes createRes = await transitionApiManager.createTransition(name, uploadRes.data!.publicUrl, duration.inMilliseconds);
    if(createRes.code != "0000") {
      ToastService.showNoticeToast("轉場建立失敗");
      return;
    }
  }

  Future<void> playTransition(String url, int index) async {
    ref.watch(transitionPlayerIndexProvider.notifier).state = index;
    ref.watch(transitionPlayerStatusProvider.notifier).state = PlayerStatus.loading;
    await _playService.prepareUrlAudio(url, onCursorChange, onComplete);
    _playService.playAudio();
    ref.watch(transitionPlayerStatusProvider.notifier).state = PlayerStatus.playing;
  }

  Future<void> stopTransition() async {
    _playService.stopAudio();
    ref.watch(transitionPlayerIndexProvider.notifier).state = null;
    ref.watch(transitionPlayerStatusProvider.notifier).state = PlayerStatus.stop;
  }

  void onCursorChange(Duration duration) {

  }

  void onComplete() {
    _playService.stopAudio();
    ref.watch(transitionPlayerIndexProvider.notifier).state = null;
    ref.watch(transitionPlayerStatusProvider.notifier).state = PlayerStatus.stop;
  }

}