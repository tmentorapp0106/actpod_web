class CreateRoomBulletinRes {
  String code;
  String message;

  CreateRoomBulletinRes(this.code, this.message);

  factory CreateRoomBulletinRes.fromJson(Map<String, dynamic> json) {
    return CreateRoomBulletinRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
    );
  }
}