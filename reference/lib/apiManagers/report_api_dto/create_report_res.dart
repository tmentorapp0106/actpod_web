class CreateReportRes {
  String code;
  String message;

  CreateReportRes(this.code, this.message);

  factory CreateReportRes.fromJson(Map<String, dynamic> json) {

    return CreateReportRes(json["code"], json["message"]);
  }
}