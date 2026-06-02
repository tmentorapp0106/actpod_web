import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_listener_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_received_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_voice_message_res.dart';
import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/services/user_service.dart';

@Entity()
class NotificationVoiceMessageDto {
  int id = 0;

  // voice message
  String? voiceMessageId;
  String? voiceMessageAudioContentId;
  String? voiceMessageAudioContentUrl;
  String? replyAudioContentId;
  String? replyAudioContentUrl;
  String? belongsToStoryId;
  String? createdByUserId;
  String? storyOwnerId;
  bool? append;
  int? appendTime;
  DateTime? uploadTime;
  DateTime? responseTime;
  DateTime? editTime; // for sorting usage
  int? donatedPodCoins;

  // story info
  String? audioContentId;
  String? audioUrl;
  String? backgroundMusicUrl;
  double? backgroundMusicVolume;
  String? storyName;
  String? storyDescription;
  String? storyImageUrl;
  String? collectionId;
  DateTime? storyUploadTime;
  String? storyStatus;
  String? voiceMessageStatus;

  String? storyOwnerAvatarUrl;
  String? storyOwnerNickname;
  String? storyOwnerSelfDescription;

  String? senderAvatarUrl;
  String? senderNickname;
  String? senderSelfDescription;

  @Transient()
  List<SoundEffectDto>? soundEffectList;

  List<String>? get soundEffectListDbData => soundEffectList?.map((soundEffect) => jsonEncode(soundEffect.toJson())).toList();
  set soundEffectListDbData(List<String>? jsonList) => soundEffectList = jsonList?.map((jsonString) => SoundEffectDto.fromJson(jsonDecode(jsonString))).toList();

  NotificationVoiceMessageDto();

  factory NotificationVoiceMessageDto.fromGetListenerVoiceMessageResItem(GetListenerVoiceMessageResItem getListenerVoiceMessageResItem) {
    final userInfo = UserService.getUserInfo()!;
    return NotificationVoiceMessageDto()
      ..voiceMessageId = getListenerVoiceMessageResItem.voiceMessageInfo.voiceMessageId
      ..voiceMessageAudioContentId = getListenerVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentId
      ..voiceMessageAudioContentUrl = getListenerVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentUrl
      ..replyAudioContentId = getListenerVoiceMessageResItem.voiceMessageInfo.replyAudioContentId
      ..replyAudioContentUrl = getListenerVoiceMessageResItem.voiceMessageInfo.replyAudioContentUrl
      ..belongsToStoryId = getListenerVoiceMessageResItem.voiceMessageInfo.belongsToStoryId
      ..createdByUserId = getListenerVoiceMessageResItem.voiceMessageInfo.createdByUserId
      ..storyOwnerId = getListenerVoiceMessageResItem.voiceMessageInfo.storyOwnerId
      ..append = getListenerVoiceMessageResItem.voiceMessageInfo.append
      ..appendTime = getListenerVoiceMessageResItem.voiceMessageInfo.appendTime
      ..uploadTime = getListenerVoiceMessageResItem.voiceMessageInfo.uploadTime
      ..responseTime = getListenerVoiceMessageResItem.voiceMessageInfo.responseTime
      ..editTime = getListenerVoiceMessageResItem.voiceMessageInfo.editTime
      ..audioContentId = getListenerVoiceMessageResItem.storyInfo.audioContentId
      ..voiceMessageStatus = getListenerVoiceMessageResItem.storyInfo.voiceMessageStatus
      ..audioUrl = getListenerVoiceMessageResItem.storyInfo.audioUrl
      ..backgroundMusicUrl = getListenerVoiceMessageResItem.storyInfo.backgroundMusicUrl?? ""
      ..backgroundMusicVolume = getListenerVoiceMessageResItem.storyInfo.backgroundMusicVolume?? 0
      ..storyName = getListenerVoiceMessageResItem.storyInfo.storyName
      ..storyDescription = getListenerVoiceMessageResItem.storyInfo.storyDescription
      ..storyImageUrl = getListenerVoiceMessageResItem.storyInfo.storyImageUrl
      ..collectionId = getListenerVoiceMessageResItem.storyInfo.collectionId
      ..storyUploadTime = getListenerVoiceMessageResItem.storyInfo.storyUploadTime
      ..storyStatus = getListenerVoiceMessageResItem.storyInfo.storyStatus
      ..storyOwnerAvatarUrl = getListenerVoiceMessageResItem.creatorInfo.avatarUrl
      ..storyOwnerNickname = getListenerVoiceMessageResItem.creatorInfo.nickname
      ..storyOwnerSelfDescription = getListenerVoiceMessageResItem.creatorInfo.selfDescription
      ..senderAvatarUrl = userInfo.avatarUrl
      ..senderNickname = userInfo.nickname
      ..senderSelfDescription = userInfo.selfDescription
      ..soundEffectList = getListenerVoiceMessageResItem.storyInfo.soundEffectList
      ..donatedPodCoins = getListenerVoiceMessageResItem.voiceMessageInfo.donatePodCoins;
  }

  factory NotificationVoiceMessageDto.fromGetReceivedVoiceMessageResItem(GetReceivedVoiceMessageResItem getReceivedVoiceMessageResItem) {
    final userInfo = UserService.getUserInfo()!;
    return NotificationVoiceMessageDto()
      ..voiceMessageId = getReceivedVoiceMessageResItem.voiceMessageInfo.voiceMessageId
      ..voiceMessageAudioContentId = getReceivedVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentId
      ..voiceMessageAudioContentUrl = getReceivedVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentUrl
      ..replyAudioContentId = getReceivedVoiceMessageResItem.voiceMessageInfo.replyAudioContentId
      ..replyAudioContentUrl = getReceivedVoiceMessageResItem.voiceMessageInfo.replyAudioContentUrl
      ..belongsToStoryId = getReceivedVoiceMessageResItem.voiceMessageInfo.belongsToStoryId
      ..createdByUserId = getReceivedVoiceMessageResItem.voiceMessageInfo.createdByUserId
      ..storyOwnerId = getReceivedVoiceMessageResItem.voiceMessageInfo.storyOwnerId
      ..append = getReceivedVoiceMessageResItem.voiceMessageInfo.append
      ..voiceMessageStatus = getReceivedVoiceMessageResItem.storyInfo.voiceMessageStatus
      ..appendTime = getReceivedVoiceMessageResItem.voiceMessageInfo.appendTime
      ..uploadTime = getReceivedVoiceMessageResItem.voiceMessageInfo.uploadTime
      ..responseTime = getReceivedVoiceMessageResItem.voiceMessageInfo.responseTime
      ..editTime = getReceivedVoiceMessageResItem.voiceMessageInfo.editTime
      ..audioContentId = getReceivedVoiceMessageResItem.storyInfo.audioContentId
      ..audioUrl = getReceivedVoiceMessageResItem.storyInfo.audioUrl
      ..backgroundMusicUrl = getReceivedVoiceMessageResItem.storyInfo.backgroundMusicUrl?? ""
      ..backgroundMusicVolume = getReceivedVoiceMessageResItem.storyInfo.backgroundMusicVolume?? 0
      ..storyName = getReceivedVoiceMessageResItem.storyInfo.storyName
      ..storyDescription = getReceivedVoiceMessageResItem.storyInfo.storyDescription
      ..storyImageUrl = getReceivedVoiceMessageResItem.storyInfo.storyImageUrl
      ..collectionId = getReceivedVoiceMessageResItem.storyInfo.collectionId
      ..storyUploadTime = getReceivedVoiceMessageResItem.storyInfo.storyUploadTime
      ..storyStatus = getReceivedVoiceMessageResItem.storyInfo.storyStatus
      ..senderAvatarUrl = getReceivedVoiceMessageResItem.listenerInfo.avatarUrl
      ..senderNickname = getReceivedVoiceMessageResItem.listenerInfo.nickname
      ..senderSelfDescription = getReceivedVoiceMessageResItem.listenerInfo.selfDescription
      ..storyOwnerAvatarUrl = userInfo.avatarUrl
      ..storyOwnerNickname = userInfo.nickname
      ..storyOwnerSelfDescription = userInfo.selfDescription
      ..soundEffectList = getReceivedVoiceMessageResItem.storyInfo.soundEffectList
      ..donatedPodCoins = getReceivedVoiceMessageResItem.voiceMessageInfo.donatePodCoins;
  }

  // factory NotificationVoiceMessageDto.fromGetVoiceMessageResItem(GetVoiceMessageResItem getVoiceMessageResItem) {
  //   return NotificationVoiceMessageDto()
  //     ..voiceMessageId = getVoiceMessageResItem.voiceMessageInfo.voiceMessageId
  //     ..voiceMessageAudioContentId = getVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentId
  //     ..voiceMessageAudioContentUrl = getVoiceMessageResItem.voiceMessageInfo.voiceMessageAudioContentUrl
  //     ..replyAudioContentId = getVoiceMessageResItem.voiceMessageInfo.replyAudioContentId
  //     ..replyAudioContentUrl = getVoiceMessageResItem.voiceMessageInfo.replyAudioContentUrl
  //     ..belongsToStoryId = getVoiceMessageResItem.voiceMessageInfo.belongsToStoryId
  //     ..createdByUserId = getVoiceMessageResItem.voiceMessageInfo.createdByUserId
  //     ..storyOwnerId = getVoiceMessageResItem.voiceMessageInfo.storyOwnerId
  //     ..append = getVoiceMessageResItem.voiceMessageInfo.append
  //     ..voiceMessageStatus = getVoiceMessageResItem.storyInfo.voiceMessageStatus
  //     ..appendTime = getVoiceMessageResItem.voiceMessageInfo.appendTime
  //     ..uploadTime = getVoiceMessageResItem.voiceMessageInfo.uploadTime
  //     ..responseTime = getVoiceMessageResItem.voiceMessageInfo.responseTime
  //     ..editTime = getVoiceMessageResItem.voiceMessageInfo.editTime
  //     ..audioContentId = getVoiceMessageResItem.storyInfo.audioContentId
  //     ..audioUrl = getVoiceMessageResItem.storyInfo.audioUrl
  //     ..backgroundMusicUrl = getVoiceMessageResItem.storyInfo.backgroundMusicUrl?? ""
  //     ..backgroundMusicVolume = getVoiceMessageResItem.storyInfo.backgroundMusicVolume?? 0
  //     ..storyName = getVoiceMessageResItem.storyInfo.storyName
  //     ..storyDescription = getVoiceMessageResItem.storyInfo.storyDescription
  //     ..storyImageUrl = getVoiceMessageResItem.storyInfo.storyImageUrl
  //     ..collectionId = getVoiceMessageResItem.storyInfo.collectionId
  //     ..storyEditTime = getVoiceMessageResItem.storyInfo.storyEditTime
  //     ..storyUploadTime = getVoiceMessageResItem.storyInfo.storyUploadTime
  //     ..storyStatus = getVoiceMessageResItem.storyInfo.storyStatus
  //     ..senderAvatarUrl = getVoiceMessageResItem.senderInfo.avatarUrl
  //     ..senderNickname = getVoiceMessageResItem.senderInfo.nickname
  //     ..senderSelfDescription = getVoiceMessageResItem.senderInfo.selfDescription
  //     ..storyOwnerAvatarUrl = getVoiceMessageResItem.storyOwnerInfo.avatarUrl
  //     ..storyOwnerNickname = getVoiceMessageResItem.storyOwnerInfo.nickname
  //     ..storyOwnerSelfDescription = getVoiceMessageResItem.storyOwnerInfo.selfDescription
  //     ..soundEffectList = getVoiceMessageResItem.storyInfo.soundEffectList
  //     ..donatedPodCoins = getVoiceMessageResItem.voiceMessageInfo.donatePodCoins;
  // }
}