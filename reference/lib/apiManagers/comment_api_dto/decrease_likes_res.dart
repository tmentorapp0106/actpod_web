class DecreaseLikesRes {
  String code;
  String message;

  DecreaseLikesRes(this.code, this.message);

  factory DecreaseLikesRes.fromJson(Map<String, dynamic> json) {
    return DecreaseLikesRes(
        json["code"],
        json["message"]
    );
  }
}