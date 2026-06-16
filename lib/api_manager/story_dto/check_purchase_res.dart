class CheckPurchaseRes {
  String code;
  String message;
  bool purchased;

  CheckPurchaseRes(this.code, this.message, this.purchased);

  factory CheckPurchaseRes.fromJson(Map<String, dynamic> json) {
    return CheckPurchaseRes(
      json["code"],
      json["message"],
      json["data"]?? false,
    );
  }
}