class IncreaseLikeRes {
  String code;
  String message;

  IncreaseLikeRes(this.code, this.message);

  factory IncreaseLikeRes.fromJson(Map<String, dynamic> json) {
    return IncreaseLikeRes(
      json["code"],
      json["message"]
    );
  }
}