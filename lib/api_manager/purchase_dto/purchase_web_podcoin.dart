class PurchaseWebPodcoinRes {
  String code;
  String message;

  PurchaseWebPodcoinRes(this.code, this.message);

  factory PurchaseWebPodcoinRes.fromJson(Map<String, dynamic> json) {
    return PurchaseWebPodcoinRes(
      json["code"] as String,
      json["message"] as String,
    );
  }
}