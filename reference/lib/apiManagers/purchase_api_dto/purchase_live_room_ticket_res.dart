class PurchaseLiveRoomTicketRes {
  String code;
  String message;

  PurchaseLiveRoomTicketRes(this.code, this.message);

  factory PurchaseLiveRoomTicketRes.fromJson(Map<String, dynamic> json) {
    return PurchaseLiveRoomTicketRes(json["code"], json["message"]);
  }
}