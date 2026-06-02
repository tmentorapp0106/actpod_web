class ExistTicketRes {
  final String code;
  final String message;
  final bool? existTicket;

  ExistTicketRes(
      this.code,
      this.message,
      this.existTicket,
      );

  factory ExistTicketRes.fromJson(Map<String, dynamic> json) {
    return ExistTicketRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] ?? false) as bool
    );
  }
}