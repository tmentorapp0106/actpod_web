class InsertExceptionLogRes {
  String code;
  String message;

  InsertExceptionLogRes(this.code, this.message);

  factory InsertExceptionLogRes.fromJson(Map<String, dynamic> json) {
    return InsertExceptionLogRes(json["code"], json["message"]);
  }
}