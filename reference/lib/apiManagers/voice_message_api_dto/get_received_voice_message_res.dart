import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/dto/voice_message_itme_dto.dart';

class GetReceivedVoiceMessageRes {
  String code;
  String message;
  List<GetReceivedVoiceMessageResItem>? voiceMessageList;

  GetReceivedVoiceMessageRes(this.code, this.message, this.voiceMessageList);

  factory GetReceivedVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    List<GetReceivedVoiceMessageResItem> voiceMessageList = json["data"] == null? [] : json["data"].map<GetReceivedVoiceMessageResItem>( (json) => GetReceivedVoiceMessageResItem.fromJson(json) ).toList();
    return GetReceivedVoiceMessageRes(json["code"], json["message"], voiceMessageList);
  }
}

class GetReceivedVoiceMessageResItem {
  VoiceMessageItemDto voiceMessageInfo;
  StoryDto storyInfo;
  UserInfoDto listenerInfo;


  GetReceivedVoiceMessageResItem(this.voiceMessageInfo, this.storyInfo, this.listenerInfo);

  factory GetReceivedVoiceMessageResItem.fromJson(Map<String, dynamic> json) {
    return GetReceivedVoiceMessageResItem(
        VoiceMessageItemDto.fromJson(json["voiceMessageInfo"]),
        StoryDto.fromJson(json["storyInfo"]),
        UserInfoDto.fromJson(json["listenerInfo"])
    );
  }
}