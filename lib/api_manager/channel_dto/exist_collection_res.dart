class ExistCollectionRes {
  String code;
  String message;
  bool exist;

  ExistCollectionRes(this.code, this.message, this.exist);

  factory ExistCollectionRes.fromJson(Map<String, dynamic> json) {
    return ExistCollectionRes(json["code"], json["message"], json["data"]);
  }
}