class CreateNewUserRes {
  String code;
  String message;
  CreateNewUserResData? data;

  CreateNewUserRes(this.code, this.message, this.data);

  factory CreateNewUserRes.fromJson(Map<String, dynamic> json) {
    if(json["data"] == null) {
      return CreateNewUserRes(json["code"], json["message"], null);
    }

    return CreateNewUserRes(json["code"], json["message"], CreateNewUserResData.fromJson(json["data"]));
  }
}

class CreateNewUserResData {
  String userToken;
  String refreshToken;
  bool finishInformationStatus;

  CreateNewUserResData(this.userToken, this.refreshToken, this.finishInformationStatus);

  factory CreateNewUserResData.fromJson(Map<String, dynamic> json) {
    return CreateNewUserResData(json["userToken"], json["refreshToken"], json["finishInformationStatus"]);
  }
}