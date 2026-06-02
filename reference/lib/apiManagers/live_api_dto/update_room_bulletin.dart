class UpdateRoomBulletinRes {
  String code;
  String message;

  UpdateRoomBulletinRes(this.code, this.message);

  factory UpdateRoomBulletinRes.fromJson(Map<String, dynamic> json) {
    return UpdateRoomBulletinRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
    );
  }
}