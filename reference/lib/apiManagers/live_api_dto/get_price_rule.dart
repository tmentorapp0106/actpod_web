import 'package:quick_share_app/dto/live_room_price_rule.dart';

class GetPriceRuleRes {
  final String code;
  final String message;
  final LiveRoomPriceRule? priceRule;

  GetPriceRuleRes(
      this.code,
      this.message,
      this.priceRule,
      );

  factory GetPriceRuleRes.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return GetPriceRuleRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      data is Map<String, dynamic>
          ? LiveRoomPriceRule.fromJson(data)
          : null,
    );
  }
}


