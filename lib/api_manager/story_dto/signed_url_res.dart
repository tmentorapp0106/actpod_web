class SignedUrlRes {
  String code;
  String message;
  String? url;

  SignedUrlRes(
    this.code,
    this.message,
    this.url
  );

  factory SignedUrlRes.fromJson(Map<String, dynamic> json) {
    return SignedUrlRes(
        json["code"],
        json["message"],
        json["data"]?? ""
    );
  }
}