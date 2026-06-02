class TransitionDto {
  String userId;
  String name;
  String url;
  int length;
  DateTime createdTime;

  TransitionDto(this.userId, this.name, this.url, this.length, this.createdTime);

  factory TransitionDto.fromJson(Map<String, dynamic> json) {
    return TransitionDto(
        json["userId"],
        json["name"],
        json["url"],
        json["length"],
        DateTime.parse(json["createdAt"]),
    );
  }
}