class BackgroundMusicListItemDto {
  String backgroundMusicName;
  String backgroundMusicUrl;
  String backgroundMusicImageUrl;
  int backgroundMusicLength;

  BackgroundMusicListItemDto(this.backgroundMusicName, this.backgroundMusicUrl, this.backgroundMusicImageUrl, this.backgroundMusicLength);

  factory BackgroundMusicListItemDto.fromJson(Map<String, dynamic> json) {
    return BackgroundMusicListItemDto(
      json["backgroundMusicName"],
      json["backgroundMusicUrl"],
      json["backgroundMusicImageUrl"],
      json["backgroundMusicLength"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "backgroundMusicName": backgroundMusicName,
      "backgroundMusicUrl": backgroundMusicUrl,
      "backgroundMusicImageUrl": backgroundMusicImageUrl,
      "backgroundMusicVolume": backgroundMusicLength
    };
  }
}