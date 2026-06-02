class CheckCapacityRes {
  String code;
  String message;

  CheckCapacityRes(this.code, this.message);

  factory CheckCapacityRes.fromJson(Map<String, dynamic> json) {
    return CheckCapacityRes(json["code"], json["message"]);
  }
}