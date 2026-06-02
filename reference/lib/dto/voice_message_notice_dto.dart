import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class VoiceMessageNoticeDto {
  int id = 0;
  String voiceMessageNoticeId;
  String to;
  String storyId;
  String storyName;
  String storyImageUrl;
  List<String> storyImageUrls;
  String channelId;
  String channelName;
  String channelImageUrl;
  String storyOwnerId;
  String collaboratorId;
  String storyOwnerName;
  String storyOwnerImageUrl;
  String noticeType;
  int count;
  String lastResponseUserType;
  String lastAction;
  String lastVoiceMessageId;
  String lastVoiceMessageSenderId;
  String lastVoiceMessageSenderName;
  String lastVoiceMessageAvatarUrl;
  int donateAmount;
  DateTime updateTime;

  @Transient()
  List<ResponseUser>? lastThreeResponseUserList;

  List<String>? get lastThreeResponseUserListDbData => lastThreeResponseUserList?.map((responseUser) => jsonEncode(responseUser.toJson())).toList();
  set lastThreeResponseUserListDbData(List<String>? jsonList) => lastThreeResponseUserList = jsonList?.map((jsonString) => ResponseUser.fromJson(jsonDecode(jsonString))).toList();

  VoiceMessageNoticeDto(
    this.voiceMessageNoticeId,
    this.to,
    this.storyId,
    this.storyName,
    this.storyImageUrl,
    this.storyImageUrls,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.storyOwnerId,
    this.collaboratorId,
    this.storyOwnerName,
    this.storyOwnerImageUrl,
    this.noticeType,
    this.count,
    this.lastResponseUserType,
    this.lastAction,
    this.lastVoiceMessageId,
    this.lastVoiceMessageSenderId,
    this.lastVoiceMessageSenderName,
    this.lastVoiceMessageAvatarUrl,
    this.donateAmount,
    this.updateTime
  );

  factory VoiceMessageNoticeDto.fromJson(Map<String, dynamic> json) {
    VoiceMessageNoticeDto dto = VoiceMessageNoticeDto(
      json["voiceMessageNoticeId"],
      json["to"],
      json["storyId"],
      json["storyName"],
      json["storyImageUrl"],
      (json["storyImageUrls"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
          ?? [],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["storyOwnerId"],
      json["collaboratorId"]?? "",
      json["storyOwnerName"],
      json["storyOwnerImageUrl"],
      json["noticeType"],
      json["count"]?? 0,
      json["lastResponseUserType"],
      json["lastAction"],
      json["lastVoiceMessageId"],
      json["lastVoiceMessageSenderId"],
      json["lastVoiceMessageSenderName"],
      json["lastVoiceMessageAvatarUrl"],
      json["donateAmount"]?? 0,
      DateTime.parse(json["updateTime"])
    );
    List<ResponseUser> lastThreeResponseUserList = json["lastThreeResponseUserList"].map<ResponseUser>((json) => ResponseUser.fromJson(json)).toList();
    dto.lastThreeResponseUserList = lastThreeResponseUserList;
    return dto;
  }
}

class ResponseUser {
  String userId;
  String userAvatarImageUrl;
  String username;

  ResponseUser(this.userId, this.userAvatarImageUrl, this.username);

  factory ResponseUser.fromJson(Map<String, dynamic> json) {
    return ResponseUser(
      json["userId"],
      json["userAvatarImageUrl"],
      json["userName"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userAvatarImageUrl": userAvatarImageUrl,
      "username": username
    };
  }
}