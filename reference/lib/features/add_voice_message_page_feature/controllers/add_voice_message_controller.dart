import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/voice_message_notice_dto.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/pre_message_recorder_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/providers.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/upload_system_api_manager.dart';
import '../../../apiManagers/voice_message_api_dto/add_voice_message_res.dart';
import '../../../dto/voice_message_dto.dart';
import '../../../providers.dart';
import '../../../services/toast_service.dart';
import '../../voice_message_page_feature/providers.dart';

class AddVoiceMessageController {
  WidgetRef _ref;
  VoiceMessageDto voiceMessageDto;

  AddVoiceMessageController(this._ref, this.voiceMessageDto);

  Future<bool> send(String concatedMessagePath, String? preMessagePath, String? afterMessagePath) async {
    _ref.watch(loadingProvider.notifier).state = true;

    Future<GetUploadUrlRes> concatMessageUploadFuture;
    Future<GetUploadUrlRes>? preMessageUploadFuture;
    Future<GetUploadUrlRes>? afterMessageUploadFuture;
    concatMessageUploadFuture = uploadApiManager.uploadConcatVoiceMessage(File(concatedMessagePath));
    if (preMessagePath != null) {
      preMessageUploadFuture = uploadApiManager.uploadPreVoiceMessage(File(preMessagePath));
    }
    if (afterMessagePath != null) {
      afterMessageUploadFuture = uploadApiManager.uploadAfterVoiceMessage(File(afterMessagePath));
    }

    String? concatMessageUrl, preMessageUrl, afterMessageUrl;
    final concatRes = await concatMessageUploadFuture;
    if(concatRes.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      return false;
    }
    concatMessageUrl = concatRes.data!.publicUrl;
    if (preMessageUploadFuture != null) {
      final preRes = await preMessageUploadFuture; // 這裡一定是 pre
      if (preRes.code != "0000") {
        _ref.watch(loadingProvider.notifier).state = false;
        return false;
      }
      preMessageUrl = preRes.data?.publicUrl;
    }

    if (afterMessageUploadFuture != null) {
      final afterRes = await afterMessageUploadFuture; // 這裡一定是 after
      if (afterRes.code != "0000") {
        _ref.watch(loadingProvider.notifier).state = false;
        return false;
      }
      afterMessageUrl = afterRes.data?.publicUrl;
    }

    AddVoiceMessageRes response = await voiceMessageApiManager.addVoiceMessage(
      voiceMessageDto.storyId,
      voiceMessageDto.voiceMessageId,
      concatMessageUrl,
      preMessageUrl,
      afterMessageUrl
    );
    if(response.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      return false;
    }

    List<VoiceMessageDto> voiceMessageList = _ref.watch(voiceMessageListProvider);
    for(VoiceMessageDto dto in voiceMessageList) {
      if(dto.voiceMessageId == voiceMessageDto.voiceMessageId) {
        dto.addStatus = "adding";
      }
    }
    _ref.watch(voiceMessageListProvider.notifier).state = [...voiceMessageList];

    ToastService.showSuccessToast("add success");
    _ref.watch(loadingProvider.notifier).state = false;
    return true;
  }
}