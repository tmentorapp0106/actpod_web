class DeleteRoomBulletinRes {
  String code;
  String message;

  DeleteRoomBulletinRes(this.code, this.message);

  factory DeleteRoomBulletinRes.fromJson(Map<String, dynamic> json) {
    return DeleteRoomBulletinRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
    );
  }
}