class UnionCodeDto {
  String userId;
  String code;

  UnionCodeDto(this.userId, this.code);

  factory UnionCodeDto.fromJson(Map<String, dynamic> json) {
    return UnionCodeDto(
      json["userId"],
      json["code"],
    );
  }
}