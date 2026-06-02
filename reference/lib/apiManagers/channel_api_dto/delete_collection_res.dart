class DeleteCollectionRes {
  String code;
  String message;

  DeleteCollectionRes(this.code, this.message);

  factory DeleteCollectionRes.fromJson(Map<String, dynamic> json) {
    return DeleteCollectionRes(json["code"], json["message"]);
  }
}