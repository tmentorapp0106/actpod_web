class SoundEffectListItemDto {
  String soundEffectName;
  String soundEffectUrl;
  int soundEffectLength;
  String soundEffectImageUrl;

  SoundEffectListItemDto(this.soundEffectName, this.soundEffectUrl, this.soundEffectLength, this.soundEffectImageUrl);

  factory SoundEffectListItemDto.fromJson(Map<String, dynamic> json) {
    return SoundEffectListItemDto(
      json["soundEffectName"],
      json["soundEffectUrl"],
      json["soundEffectLength"],
      json["soundEffectImageUrl"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "soundEffectName": soundEffectName,
      "soundEffectUrl": soundEffectUrl,
      "soundEffectLength": soundEffectLength,
      "soundEffectImageUrl": soundEffectImageUrl
    };
  }
}