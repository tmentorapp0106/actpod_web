class CreateTransitionRes {
  String code;
  String message;

  CreateTransitionRes(this.code, this.message);

  factory CreateTransitionRes.fromJson(Map<String, dynamic> json) {
    return CreateTransitionRes(json["code"], json["message"]);
  }
}