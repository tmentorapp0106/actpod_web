import 'package:quick_share_app/dto/voice_message_dto.dart';

class GetVoiceMessageRes {
  String code;
  String message;
  List<VoiceMessageDto>? voiceMessageList;

  GetVoiceMessageRes(this.code, this.message, this.voiceMessageList);

  factory GetVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    List<VoiceMessageDto> voiceMessageList = json["data"] == null? [] : json["data"].map<VoiceMessageDto>( (json) => VoiceMessageDto.fromJson(json) ).toList();
    return GetVoiceMessageRes(json["code"], json["message"], voiceMessageList);
  }
}