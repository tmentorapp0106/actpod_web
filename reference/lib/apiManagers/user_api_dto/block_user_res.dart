class BlockUserRes {
  String code;
  String message;

  BlockUserRes(this.code, this.message);

  factory BlockUserRes.fromJson(Map<String, dynamic> json) {
    return BlockUserRes(json["code"], json["message"]);
  }
}