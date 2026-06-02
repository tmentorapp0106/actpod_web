class MembershipLevelInfoDto {
  String customerLevel;
  String androidId;
  String iosId;
  String title;
  int price;
  List<String> contents;

  MembershipLevelInfoDto(
    this.customerLevel,
    this.androidId,
    this.iosId,
    this.title,
    this.price,
    this.contents
  );

  factory MembershipLevelInfoDto.fromJson(Map<String, dynamic> json) {
    return MembershipLevelInfoDto(
      json['customerLevel'] as String,
      json['androidId'] as String,
      json['iosId'] as String,
      json['title'] as String,
      json['price']?? 0,
      List<String>.from(json['contents'] as List),
    );
  }
}