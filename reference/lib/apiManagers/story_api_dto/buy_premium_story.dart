class BuyPremiumStoryRes {
  String code;
  String message;

  BuyPremiumStoryRes(this.code, this.message);

  factory BuyPremiumStoryRes.fromJson(Map<String, dynamic> json) {
    return BuyPremiumStoryRes(json["code"], json["message"]);
  }
}