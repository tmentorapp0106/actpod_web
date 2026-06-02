import 'dart:convert';
import 'package:objectbox/objectbox.dart';

@Entity()
class VoiceMessageDto {
  int id = 0;
  String voiceMessageId;
  String storyId;
  String storyOwnerId;
  String collaboratorId;
  String listenerId;
  String listenerName;
  String listenerAvatarImageUrl;
  String url;
  int length;
  String acceptAdd;
  String addStatus;
  int donateAmount;
  @Property(type: PropertyType.date)
  DateTime uploadTime;
  @Property(type: PropertyType.date)
  DateTime updateTime;

  @Transient()
  List<ResponseDto>? responseList;

  String? transcription;

  List<String>? get responseListDbData => responseList?.map((responseDto) => jsonEncode(responseDto.toJson())).toList();
  set responseListDbData(List<String>? jsonList) => responseList = jsonList?.map((jsonString) => ResponseDto.fromJson(jsonDecode(jsonString))).toList();

  VoiceMessageDto(
    this.voiceMessageId,
    this.storyId,
    this.storyOwnerId,
    this.collaboratorId,
    this.listenerId,
    this.listenerName,
    this.listenerAvatarImageUrl,
    this.url,
    this.length,
    this.acceptAdd,
    this.addStatus,
    this.donateAmount,
    this.uploadTime,
    this.updateTime
  );

  factory VoiceMessageDto.fromJson(Map<String, dynamic> json) {
    VoiceMessageDto dto = VoiceMessageDto(
      json["voiceMessageId"],
      json["storyId"],
      json["storyOwnerId"],
      json["collaboratorId"]?? "",
      json["listenerId"],
      json["listenerName"],
      json["listenerAvatarImageUrl"],
      json["url"],
      json["length"],
      json["acceptAdd"],
      json["addStatus"],
      json["donateAmount"]?? 0,
      DateTime.parse(json["uploadTime"]),
      DateTime.parse(json["updateTime"])
    );
    List<ResponseDto> responseDtoList = json["responseList"].map<ResponseDto>((json) => ResponseDto.fromJson(json)).toList();
    dto.responseList = responseDtoList;
    return dto;
  }
}

@Entity()
class ResponseDto {
  int id = 0;
  String responseId;
  String userId;
  String userName;
  String userAvatarImageUrl;
  String url;
  int length;
  DateTime uploadTime;

  ResponseDto(
    this.responseId,
    this.userId,
    this.userName,
    this.userAvatarImageUrl,
    this.url,
    this.length,
    this.uploadTime
  );

  factory ResponseDto.fromJson(Map<String, dynamic> json) {
    return ResponseDto(
      json["responseId"],
      json["userId"],
      json["userName"],
      json["userAvatarImageUrl"],
      json["url"],
      json["length"],
      DateTime.parse(json["uploadTime"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "responseId": responseId,
      "userId": userId,
      "userName": userName,
      "userAvatarImageUrl": userAvatarImageUrl,
      "url": url,
      "length": length,
      "uploadTime": uploadTime
    };
  }
}