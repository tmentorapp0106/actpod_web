class RemoveBlockUserRes {
  String code;
  String message;

  RemoveBlockUserRes(this.code, this.message);

  factory RemoveBlockUserRes.fromJson(Map<String, dynamic> json) {
    return RemoveBlockUserRes(json["code"], json["message"]);
  }
}