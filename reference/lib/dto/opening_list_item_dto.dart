class OpeningListItemDto {
  String openingName;
  String openingUrl;
  String openingImageUrl;
  int openingLength;

  OpeningListItemDto(this.openingName, this.openingUrl, this.openingImageUrl, this.openingLength);

  factory OpeningListItemDto.fromJson(Map<String, dynamic> json) {
    return OpeningListItemDto(
        json["openingName"],
        json["openingUrl"],
        json["openingImageUrl"],
        json["openingLength"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "openingName": openingName,
      "openingUrl": openingUrl,
      "openingImageUrl": openingImageUrl,
      "openingLength": openingLength
    };
  }
}