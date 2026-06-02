class WithdrawDto {
  String withdrawId;
  String status;
  String userId;
  int podcash;
  String email;
  String phone;
  DateTime? transferTime;
  DateTime createTime;
  DateTime updateTime;

  WithdrawDto({
    required this.withdrawId,
    required this.status,
    required this.userId,
    required this.podcash,
    required this.email,
    required this.phone,
    required this.createTime,
    required this.updateTime,
    this.transferTime,
  });

  factory WithdrawDto.fromJson(Map<String, dynamic> json) {
    return WithdrawDto(
      withdrawId: json['withdrawId'] as String,
      status: json['status'] as String,
      userId: json['userId'] as String,
      podcash: json['podCash'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String,
      transferTime: json['transferTime'] != null
          ? DateTime.parse(json['transferTime'] as String)
          : null,
      createTime: DateTime.parse(json['createTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withdrawId': withdrawId,
      'status': status,
      'userId': userId,
      'podcash': podcash,
      'email': email,
      'phone': phone,
      'transferTime': transferTime?.toIso8601String(),
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }
}