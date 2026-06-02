class FindAudiosRes {
  String code;
  String message;
  List<FindAudiosResItem>? audioList;

  FindAudiosRes(this.code, this.message, this.audioList);

  factory FindAudiosRes.fromJson(Map<String, dynamic> json) {
    return FindAudiosRes(
      json["code"], 
      json["message"],
      json["data"]?.map<FindAudiosResItem>((json) => FindAudiosResItem.fromJson(json)).toList()
    );
  }
}

class FindAudiosResItem {
  String audioId;
  String userId;
  String audioName;
  String audioUrl;
  int length;
  String audioType;

  FindAudiosResItem(
    this.audioId,
    this.userId,
    this.audioName,
    this.audioUrl,
    this.length,
    this.audioType
  );

  factory FindAudiosResItem.fromJson(Map<String, dynamic> json) {
    return FindAudiosResItem(
      json["audioId"], 
      json["userId"],
      json["audioName"],
      json["audioUrl"],
      json["length"],
      json["audioType"]
    );
  }
}