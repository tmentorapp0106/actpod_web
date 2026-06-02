class SpaceApplicationRes {
  String code;
  String message;

  SpaceApplicationRes(this.code, this.message);

  factory SpaceApplicationRes.fromJson(Map<String, dynamic> json) {
    return SpaceApplicationRes(json["code"], json["message"]);
  }
}