class CheckExistRes {
  String code;
  String message;
  bool exist;

  CheckExistRes(this.code, this.message, this.exist);

  factory CheckExistRes.fromJson(Map<String, dynamic> json) {
    return CheckExistRes(
      json["code"],
      json["message"],
      json["data"]
    );
  }
}