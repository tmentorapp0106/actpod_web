class RemoveAccountRes {
  String code;
  String message;

  RemoveAccountRes(this.code, this.message);

  factory RemoveAccountRes.fromJson(Map<String, dynamic> json) {
    return RemoveAccountRes(json["code"], json["message"]);
  }
}