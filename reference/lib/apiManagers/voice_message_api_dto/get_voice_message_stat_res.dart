import '../../dto/voice_message_stat_dto.dart';

class GetVoiceMessageStatRes {
  String code;
  String message;
  VoiceMessageStatDto? voiceMessageStat;

  GetVoiceMessageStatRes(this.code, this.message, this.voiceMessageStat);

  factory GetVoiceMessageStatRes.fromJson(Map<String, dynamic> json) {
    return GetVoiceMessageStatRes(
        json["code"],
        json["message"],
        json["data"] == null? null : VoiceMessageStatDto.fromJson(json["data"])
    );
  }
}