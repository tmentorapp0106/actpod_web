class CreateCollectionRes {
  String code;
  String message;
  String collectionId;

  CreateCollectionRes(this.code, this.message, this.collectionId);

  factory CreateCollectionRes.fromJson(Map<String, dynamic> json) {
    return CreateCollectionRes(json["code"], json["message"], json["data"] ?? "");
  }
}