import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/voice_message_api_dto/get_voice_message_res.dart';
import '../providers.dart';

class VoiceMessageController {
  WidgetRef _ref;

  VoiceMessageController(this._ref);

  Future<void> getStoryVoiceMessage(String storyId, String storyOwnerId, String collaboratorId) async {
    GetVoiceMessageRes response;
    if(storyOwnerId == UserService.getUserInfo()?.userId || collaboratorId == UserService.getUserInfo()?.userId) {
      response = await voiceMessageApiManager.getStoryVoiceMessage(storyId);
      if(response.code != "0000") {
        print(response.message);
        return;
      }
    } else {
      response = await voiceMessageApiManager.getStoryVoiceMessageWithUserId(storyId, UserService.getUserInfo()!.userId);
      if(response.code != "0000") {
        print(response.message);
        return;
      }
    }

    for(int i = 0; i < response.voiceMessageList!.length; i++) {
      _ref.watch(voiceMessageWidgetKey).add(GlobalKey());
      _ref.watch(voiceMessageWidgetKey.notifier).state = [..._ref.watch(voiceMessageWidgetKey)];
    }
    _ref.watch(voiceMessageListProvider.notifier).state = response.voiceMessageList?? [];
  }
}