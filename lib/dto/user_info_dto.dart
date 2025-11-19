class UserInfoDto {
  int id = 0;
  String userId;
  String avatarUrl;
  String username;
  String nickname;
  String gender;
  String email;
  String selfDescription;

  UserInfoDto(this.userId, this.avatarUrl, this.username, this.nickname, this.gender, this.email, this.selfDescription);

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(json["userId"], json["avatarUrl"], json["username"],
        json["nickname"], json["gender"], json["email"], json["selfDescription"]);
  }

  Map toJson() => {
    'userId': userId,
    'avatarUrl': avatarUrl,
    'username': username,
    'nickname': nickname,
    'gender': gender,
    'email': email,
    'selfDescription': selfDescription
  };
}