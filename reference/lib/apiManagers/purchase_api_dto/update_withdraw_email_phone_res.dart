class UpdateWithdrawEmailPhoneRes {
  String code;
  String message;

  UpdateWithdrawEmailPhoneRes(this.code, this.message);

  factory UpdateWithdrawEmailPhoneRes.fromJson(Map<String, dynamic> json) {
    return UpdateWithdrawEmailPhoneRes(
      json["code"],
      json["message"],
    );
  }
}