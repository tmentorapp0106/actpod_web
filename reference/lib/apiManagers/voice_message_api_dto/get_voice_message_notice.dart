import 'package:quick_share_app/dto/voice_message_notice_dto.dart';

class GetVoiceMessageNoticeRes {
  String code;
  String message;
  List<VoiceMessageNoticeDto>? voiceMessageNoticeList;

  GetVoiceMessageNoticeRes(this.code, this.message, this.voiceMessageNoticeList);

  factory GetVoiceMessageNoticeRes.fromJson(Map<String, dynamic> json) {
    List<VoiceMessageNoticeDto>? voiceMessageNoticeList = json["data"] == null? [] : json["data"].map<VoiceMessageNoticeDto>( (json) => VoiceMessageNoticeDto.fromJson(json)).toList();
    return GetVoiceMessageNoticeRes(json["code"], json["message"], voiceMessageNoticeList);
  }
}