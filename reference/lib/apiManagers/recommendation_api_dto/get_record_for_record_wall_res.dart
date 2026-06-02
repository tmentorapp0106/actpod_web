class GetRecordWallRecordsRes {
  String code;
  String message;
  List<GetRecordWallRecordsResItem>? recordList;

  GetRecordWallRecordsRes(this.code, this.message, this.recordList);

  factory GetRecordWallRecordsRes.fromJson(Map<String, dynamic> json) {
    List<GetRecordWallRecordsResItem> classRecordList = json["data"]
        .map<GetRecordWallRecordsResItem>(
            (json) => GetRecordWallRecordsResItem.fromJson(json))
        .toList();
    return GetRecordWallRecordsRes(
        json["code"], json["message"], classRecordList);
  }
}

class GetRecordWallRecordsResItem {
  String recordId;
  String recordUrl;
  String channelId;
  String channelName;
  String recordName;
  String recordDescription;
  String channelImageUrl;
  bool openVoiceMessage;

  GetRecordWallRecordsResItem(
      this.recordId,
      this.recordUrl,
      this.channelId,
      this.channelName,
      this.recordName,
      this.recordDescription,
      this.channelImageUrl,
      this.openVoiceMessage);

  factory GetRecordWallRecordsResItem.fromJson(Map<String, dynamic> json) {
    return GetRecordWallRecordsResItem(
        json["recordId"],
        json["recordUrl"],
        json["channelId"],
        json["channelName"],
        json["recordName"],
        json["recordDescription"],
        json["channelImageUrl"],
        json["openVoiceMessage"]);
  }
}
