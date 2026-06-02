import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/send_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/voice_message_notice_dto.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../apiManagers/voice_message_api_dto/get_voice_message_notice.dart';
import '../../../dto/user_info_dto.dart';
import '../../../dto/voice_message_dto.dart';
import '../../../providers.dart';
import '../providers.dart';

class SendController {
  WidgetRef ref;

  SendController(this.ref);

  Future<ResponseDto?> sendResponse(String audioFilePath, VoiceMessageDto voiceMessageDto) async {
    ref.watch(responseStatusProvider.notifier).state = "uploading";
    ref.watch(loadingProvider.notifier).state = true;

    GetUploadUrlRes uploadAudioResponse;
    try {
      uploadAudioResponse = await uploadApiManager.uploadVoiceMessageAudio(File(audioFilePath));
      if(uploadAudioResponse.code != "0000") {
        ToastService.showNoticeToast(uploadAudioResponse.message);
        ref.watch(responseStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return null;
      }
    } catch(e) {
      ToastService.showNoticeToast("Unexpected error");
      ref.watch(loadingProvider.notifier).state = false;
      return null;
    }

    Duration? length = await AudioUtils.getAudioFileLength(audioFilePath);
    UserInfoDto? userInfoDto = UserService.getUserInfo();
    SendVoiceMessageRes res;
    if(voiceMessageDto.storyOwnerId == userInfoDto?.userId) {
      res = await voiceMessageApiManager.storyOwnerSendResponse(voiceMessageDto.storyId, voiceMessageDto.voiceMessageId, uploadAudioResponse.data!.publicUrl, length!);
      if(res.code != "0000") {
        ToastService.showNoticeToast(res.message);
        ref.watch(responseStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return null;
      }
    } else if(voiceMessageDto.collaboratorId == userInfoDto?.userId) {
      res = await voiceMessageApiManager.collaboratorSendResponse(voiceMessageDto.storyId, voiceMessageDto.voiceMessageId, uploadAudioResponse.data!.publicUrl, length!);
      if(res.code != "0000") {
        ToastService.showNoticeToast(res.message);
        ref.watch(responseStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return null;
      }
    } else {
      res = await voiceMessageApiManager.listenerSendResponse(voiceMessageDto.storyId, voiceMessageDto.voiceMessageId, uploadAudioResponse.data!.publicUrl, length!);
      if(res.code != "0000") {
        ToastService.showNoticeToast(res.message);
        ref.watch(responseStatusProvider.notifier).state = "pending";
        ref.watch(loadingProvider.notifier).state = false;
        return null;
      }
    }
    GetVoiceMessageNoticeRes response = await voiceMessageApiManager.getUserVoiceMessageNotice("story");
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return null;
    }
    ref.watch(storyVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    response = await voiceMessageApiManager.getUserVoiceMessageNotice("listened");
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return null;
    }
    ref.watch(listenedVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    ref.watch(loadingProvider.notifier).state = false;
    ToastService.showSuccessToast("語音訊息傳送成功");
    ref.watch(responseStatusProvider.notifier).state = "pending";
    return ResponseDto(res.messageId, userInfoDto!.userId, userInfoDto.nickname, userInfoDto.avatarUrl, uploadAudioResponse.data!.publicUrl, length.inMilliseconds, DateTime.now());
  }
}