import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/send_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/purchase_api_dto/get_user_purses_res.dart';
import '../../../apiManagers/voice_message_api_dto/get_voice_message_notice.dart';
import '../../../providers.dart';
import '../../../services/review_rating_service.dart';
import '../../voice_message_notice_page_feature/providers.dart';

class SendController {
  WidgetRef ref;

  SendController(this.ref);

  Future<void> sendVoiceMessage(String audioFilePath, String storyId, int donateAmount, String acceptAdd) async {
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "uploading";
    ref.watch(loadingProvider.notifier).state = true;

    GetUploadUrlRes uploadAudioResponse;
    try {
      uploadAudioResponse = await uploadApiManager.uploadVoiceMessageAudio(File(audioFilePath));
      if(uploadAudioResponse.code != "0000") {
        ToastService.showNoticeToast(uploadAudioResponse.message);
        ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return;
      }
    } catch(e) {
      ToastService.showNoticeToast("Unexpected error");
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    Duration? length = await AudioUtils.getAudioFileLength(audioFilePath);
    SendVoiceMessageRes res = await voiceMessageApiManager.sendVoiceMessage(
      storyId,
      uploadAudioResponse.data!.publicUrl,
      length!,
      donateAmount,
      acceptAdd
    );
    if(res.code != "0000") {
      ToastService.showNoticeToast(res.message);
      ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
    if(donateAmount == 0) {
      ToastService.showSuccessToast("您已傳送語音留言");
      ReviewRatingService.ratingForFirstTime();
    } else {
      GetUserPursesRes response = await purchaseApiManager.getUserPurses();
      if(response.code == "0000") {
        ref.watch(userPodCoinsProvider.notifier).state = response.purses!.coinsPurse.podCoins;
      }
      ToastService.showSuccessToast("您已傳送語音留言並贊助創作者");
      ReviewRatingService.ratingForFirstTime();
    }

    GetVoiceMessageNoticeRes response = await voiceMessageApiManager.getUserVoiceMessageNotice("story");
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
    }
    ref.watch(storyVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    response = await voiceMessageApiManager.getUserVoiceMessageNotice("listened");
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
    }
    ref.watch(listenedVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
  }

  Future<void> sendDirectVoiceMessage(String audioFilePath, String storyId) async {
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "uploading";
    ref.watch(loadingProvider.notifier).state = true;

    GetUploadUrlRes uploadAudioResponse;
    try {
      uploadAudioResponse = await uploadApiManager.uploadVoiceMessageAudio(File(audioFilePath));
      if(uploadAudioResponse.code != "0000") {
        ToastService.showNoticeToast(uploadAudioResponse.message);
        ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return;
      }
    } catch(e) {
      ToastService.showNoticeToast("Unexpected error");
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    SendVoiceMessageRes res = await voiceMessageApiManager.sendDirectVoiceMessage(storyId, uploadAudioResponse.data!.publicUrl);
    if(res.code != "0000") {
      ToastService.showNoticeToast(res.message);
      ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
    ToastService.showSuccessToast("您已添加語音");
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
  }
}