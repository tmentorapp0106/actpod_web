class CreateWithdrawRes {
  String code;
  String message;

  CreateWithdrawRes(this.code, this.message);

  factory CreateWithdrawRes.fromJson(Map<String, dynamic> json) {
    return CreateWithdrawRes(
      json["code"],
      json["message"],
    );
  }
}