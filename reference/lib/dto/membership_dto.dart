class MembershipDto {
  String userId;
  String customerLevel;
  int fee;
  DateTime expireTime;
  String paymentMethod;
  String unionCode;
  DateTime createTime;
  DateTime updateTime;

  MembershipDto({
    required this.userId,
    required this.customerLevel,
    required this.fee,
    required this.expireTime,
    required this.paymentMethod,
    required this.unionCode,
    required this.createTime,
    required this.updateTime,
  });

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    return MembershipDto(
      userId: json["userId"] ?? "",
      customerLevel: json["customerLevel"] ?? "",
      fee: json["fee"] ?? 0,
      expireTime: DateTime.parse(json["expireTime"]),
      paymentMethod: json["paymentMethod"] ?? "",
      unionCode: json["unionCode"]?? "",
      createTime: DateTime.parse(json["createTime"]),
      updateTime: DateTime.parse(json["updateTime"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "customerLevel": customerLevel,
      "fee": fee,
      "expireTime": expireTime.toIso8601String(),
      "paymentMethod": paymentMethod,
      "createTime": createTime.toIso8601String(),
      "updateTime": updateTime.toIso8601String(),
    };
  }

  MembershipDto copyWith({
    String? userId,
    String? customerLevel,
    int? fee,
    DateTime? expireTime,
    String? paymentMethod,
    String? unionCode,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return MembershipDto(
      userId: userId ?? this.userId,
      customerLevel: customerLevel ?? this.customerLevel,
      fee: fee ?? this.fee,
      expireTime: expireTime ?? this.expireTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      unionCode: unionCode ?? this.unionCode,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}