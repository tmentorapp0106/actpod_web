class PurchaseCoinRes {
  String code;
  String message;

  PurchaseCoinRes(this.code, this.message);

  factory PurchaseCoinRes.fromJson(Map<String, dynamic> json) {
    return PurchaseCoinRes(json["code"], json["message"]);
  }
}