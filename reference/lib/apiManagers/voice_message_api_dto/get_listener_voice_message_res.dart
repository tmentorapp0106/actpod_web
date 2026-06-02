import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/dto/voice_message_itme_dto.dart';

class GetListenerVoiceMessageRes {
  String code;
  String message;
  List<GetListenerVoiceMessageResItem>? voiceMessageList;

  GetListenerVoiceMessageRes(this.code, this.message, this.voiceMessageList);

  factory GetListenerVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    List<GetListenerVoiceMessageResItem> voiceMessageList = json["data"] == null? [] : json["data"].map<GetListenerVoiceMessageResItem>( (json) => GetListenerVoiceMessageResItem.fromJson(json) ).toList();
    return GetListenerVoiceMessageRes(json["code"], json["message"], voiceMessageList);
  }
}

class GetListenerVoiceMessageResItem {
  VoiceMessageItemDto voiceMessageInfo;
  StoryDto storyInfo;
  UserInfoDto creatorInfo;


  GetListenerVoiceMessageResItem(this.voiceMessageInfo, this.storyInfo, this.creatorInfo);

  factory GetListenerVoiceMessageResItem.fromJson(Map<String, dynamic> json) {
    return GetListenerVoiceMessageResItem(
      VoiceMessageItemDto.fromJson(json["voiceMessageInfo"]),
      StoryDto.fromJson(json["storyInfo"]),
      UserInfoDto.fromJson(json["creatorInfo"])
    );
  }
}