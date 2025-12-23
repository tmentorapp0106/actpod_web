class InteractiveContentDto {
  String storyId;
  String url;
  List<InteractiveMessageInfoDto> messageInfoList;

  InteractiveContentDto(
    this.storyId,
    this.url,
    this.messageInfoList,
  );

  factory InteractiveContentDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messageList = json["messageInfoList"];
    final List<InteractiveMessageInfoDto> messageInfoList = messageList
        .map((e) => InteractiveMessageInfoDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return InteractiveContentDto(
      json["storyId"],
      json["url"],
      messageInfoList,
    );
  }
}

class InteractiveMessageInfoDto {
  String userId;
  String nickname;
  String avatarUrl;
  String voiceMessageId;
  String messageId;
  int fromMilliSec;
  int toMilliSec;

  InteractiveMessageInfoDto(
    this.userId,
    this.nickname,
    this.avatarUrl,
    this.voiceMessageId,
    this.messageId,
    this.fromMilliSec,
    this.toMilliSec
  );

  factory InteractiveMessageInfoDto.fromJson(Map<String, dynamic> json) {
    return InteractiveMessageInfoDto(
      json["userId"],
      json["nickname"],
      json["avatarUrl"],
      json["voiceMessageId"],
      json["messageId"],
      json["fromMilliSec"],
      json["toMilliSec"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "nickname": nickname,
      "avatarUrl": avatarUrl,
      "voiceMessageId": voiceMessageId,
      "messageId": messageId,
      "fromMilliSec": fromMilliSec,
      "toMilliSec": toMilliSec,
    };
  }
}