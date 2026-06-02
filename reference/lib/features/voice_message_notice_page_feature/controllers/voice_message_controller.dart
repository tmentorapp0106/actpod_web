import 'package:async/async.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/notification_voice_message_dto.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';
import 'package:quick_share_app/local_storage/repositories/notification_voice_message_repository.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/voice_message_api_dto/get_voice_message_notice.dart';
import '../../../apiManagers/voice_message_api_dto/get_voice_message_res.dart';

class VoiceMessageController {
  WidgetRef _ref;
  final PlayerController _senderPlayerController = PlayerController();
  final PlayerController _responsePlayerController = PlayerController();
  int _page = 1;
  bool _noMore = false;
  final int _pageSize = 20;

  VoiceMessageController(this._ref);

  void dispose() {
    _senderPlayerController.dispose();
    _responsePlayerController.dispose();
  }

  Future<void> getVoiceMessages(BuildContext context, bool reset) async {
    GetVoiceMessageNoticeRes response = await voiceMessageApiManager.getUserVoiceMessageNotice("story");
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    if(context.mounted) {
      _ref.watch(storyVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    }
    response = await voiceMessageApiManager.getUserVoiceMessageNotice("listened");
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    if(context.mounted) {
      _ref.watch(listenedVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    }

    // if(reset) {
    //   _page = 1;
    // }
    // _ref.watch(notificationVoiceMessageListProvider.notifier).state = notificationVoiceMessageRepository.getAllVoiceMessagesByUserId(UserService.getUserInfo()!.userId)!;
    // notificationVoiceMessageRepository.removeAllVoiceMessagesByUserId(UserService.getUserInfo()!.userId);
    // await getVoiceMessage();
    // _ref.watch(notificationVoiceMessageListProvider.notifier).state = notificationVoiceMessageRepository.getAllVoiceMessagesByUserId(UserService.getUserInfo()!.userId)!;
  }

  Future<void> getVoiceMessage() async {
    // GetVoiceMessageRes response = await voiceMessageApiManager.getVoiceMessages(_page++, _pageSize);
    // if(response.code != "0000") {
    //   ToastService.showNoticeToast(response.message);
    //   return;
    // }
    //
    // final notificationMessageList = response.voiceMessageList?.map((listenerMessage) => NotificationVoiceMessageDto.fromGetVoiceMessageResItem(listenerMessage)).toList();
    // notificationVoiceMessageRepository.insertManyMessages(notificationMessageList!);
  }

  Future<void> getMoreVoiceMessages() async {
    // if(_noMore) {
    //   return;
    // }
    // GetVoiceMessageRes response = await voiceMessageApiManager.getVoiceMessages(_page++, _pageSize);
    // if(response.code != "0000") {
    //   ToastService.showNoticeToast(response.message);
    //   return;
    // }
    //
    // final notificationMessageList = response.voiceMessageList?.map((listenerMessage) => NotificationVoiceMessageDto.fromGetVoiceMessageResItem(listenerMessage)).toList();
    // if(notificationMessageList == null || notificationMessageList.isEmpty) {
    //   _noMore = true;
    //   return;
    // }
    // List<NotificationVoiceMessageDto> originList = _ref.watch(notificationVoiceMessageListProvider);
    // _ref.watch(notificationVoiceMessageListProvider.notifier).state = originList + notificationMessageList;
  }
}