class GetChannelVoiceMessageRes {
  String code;
  String message;
  List<GetChannelVoiceMessageResItem>? voiceMessageList;

  GetChannelVoiceMessageRes(this.code, this.message, this.voiceMessageList);

  factory GetChannelVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    List<GetChannelVoiceMessageResItem> voiceMessageList = json["data"] == null? [] : json["data"].map<GetChannelVoiceMessageResItem>( (json) => GetChannelVoiceMessageResItem.fromJson(json) ).toList();
    return GetChannelVoiceMessageRes(json["code"], json["message"], voiceMessageList);
  }
}

class GetChannelVoiceMessageResItem {
  String messageId;
  String messageUrl;
  String responseUrl;
  String channelId;
  String recordId;
  String listenerId;
  int messageTime;
  int appendTime;
  DateTime sendTime;
  DateTime responseTime;

  GetChannelVoiceMessageResItem(this.messageId, this.messageUrl, this.responseUrl, this.channelId, this.recordId, this.listenerId, this.messageTime, this.appendTime, this.sendTime, this.responseTime);

  factory GetChannelVoiceMessageResItem.fromJson(Map<String, dynamic> json) {
    return GetChannelVoiceMessageResItem(
      json["messageId"],
      json["messageUrl"],
      json["responseUrl"],
      json["channelId"],
      json["recordId"],
      json["listenerId"],
      json["messageTime"],
      json["appendTime"],
      DateTime.parse(json["sendTime"]),
      DateTime.parse(json["responseTime"])
    );
  }
}