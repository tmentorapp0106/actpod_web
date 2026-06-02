import 'package:objectbox/objectbox.dart';

@Entity()
class VoiceMessageItemDto {
  int id = 0;
  String voiceMessageId;
  String voiceMessageAudioContentId;
  String voiceMessageAudioContentUrl;
  String replyAudioContentId;
  String replyAudioContentUrl;
  String belongsToStoryId;
  String createdByUserId;
  String storyOwnerId;
  bool append;
  int appendTime;
  DateTime uploadTime;
  DateTime responseTime;
  DateTime editTime;
  int donatePodCoins;

  VoiceMessageItemDto(
      this.voiceMessageId, this.voiceMessageAudioContentId, this.voiceMessageAudioContentUrl, this.replyAudioContentId, this.replyAudioContentUrl,
      this.belongsToStoryId, this.createdByUserId, this.storyOwnerId, this.append, this.appendTime, this.uploadTime,
      this.responseTime, this.editTime, this.donatePodCoins);

  factory VoiceMessageItemDto.fromJson(Map<String, dynamic> json) {
    return VoiceMessageItemDto(
        json["voiceMessageId"],
        json["voiceMessageAudioContentId"],
        json["voiceMessageAudioContentUrl"],
        json["replyAudioContentId"],
        json["replyAudioContentUrl"],
        json["belongsToStoryId"],
        json["createdByUserId"],
        json["storyOwnerId"],
        json["append"],
        json["appendTime"],
        DateTime.parse(json["uploadTime"]),
        DateTime.parse(json["responseTime"]),
        DateTime.parse(json["editTime"]),
        json["donatedPodCoins"]
    );
  }
}