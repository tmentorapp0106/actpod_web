class CreateCreditCardPaymentRes {
  String code;
  String message;
  CreditCardPayment? creditCardPayment;

  CreateCreditCardPaymentRes(this.code, this.message, this.creditCardPayment);

  factory CreateCreditCardPaymentRes.fromJson(Map<String, dynamic> json) {
    return CreateCreditCardPaymentRes(
        json["code"],
        json["message"],
        json["data"] == null? null : CreditCardPayment.fromJson(json["data"])
    );
  }
}

class CreditCardPayment {
  String gatewayURL;
  String method;
  String merchantID;
  String merchantOrderNo;
  int amt;
  String version;
  String tradeInfo;
  String tradeSha;
  Map<String, String> form;

  CreditCardPayment(
    this.gatewayURL,
    this.method,
    this.merchantID,
    this.merchantOrderNo,
    this.amt,
    this.version,
    this.tradeInfo,
    this.tradeSha,
    this.form,
  );

  factory CreditCardPayment.fromJson(Map<String, dynamic> json) {
    return CreditCardPayment(
      (json['gatewayURL'] ?? '') as String,
      (json['method'] ?? '') as String,
      (json['merchantID'] ?? '') as String,
      (json['merchantOrderNo'] ?? '') as String,
      (json['amt'] ?? 0) as int,
      (json['version'] ?? '') as String,
      (json['tradeInfo'] ?? '') as String,
      (json['tradeSha'] ?? '') as String,
      (json['form'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value.toString())),
    );
  }
}