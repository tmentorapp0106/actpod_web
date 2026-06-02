import 'package:quick_share_app/dto/withdraw_dto.dart';

class GetWithdrawsRes {
  String code;
  String message;
  List<WithdrawDto>? withdraws;

  GetWithdrawsRes(this.code, this.message, this.withdraws);

  factory GetWithdrawsRes.fromJson(Map<String, dynamic> json) {
    return GetWithdrawsRes(
      json['code'] as String,
      json['message'] as String,
      json["data"] == null? [] : json["data"]
          .map<WithdrawDto>(
              (json) => WithdrawDto.fromJson(json))
          .toList()
    );
  }
}