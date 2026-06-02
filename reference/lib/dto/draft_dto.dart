class DraftDto {
  String userId;
  String draftId;
  String audioFileUrl;
  String blockInfoFileUrl;
  DateTime createTime;

  DraftDto({
    required this.userId,
    required this.draftId,
    required this.audioFileUrl,
    required this.blockInfoFileUrl,
    required this.createTime,
  });

  /// Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "draftId": draftId,
      "audioFileUrl": audioFileUrl,
      "blockInfoFileUrl": blockInfoFileUrl,
      "createTime": createTime.toIso8601String(),
    };
  }

  /// Convert JSON to Dart object
  factory DraftDto.fromJson(Map<String, dynamic> json) {
    return DraftDto(
      userId: json['userId'],
      draftId: json['draftId'],
      audioFileUrl: json['audioFileUrl'],
      blockInfoFileUrl: json['blockInfoFileUrl'],
      createTime: DateTime.parse(json['createTime']),
    );
  }
}