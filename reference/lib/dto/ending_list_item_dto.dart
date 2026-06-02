class EndingListItemDto {
  String endingName;
  String endingUrl;
  String endingImageUrl;
  int endingLength;

  EndingListItemDto(this.endingName, this.endingUrl, this.endingImageUrl, this.endingLength);

  factory EndingListItemDto.fromJson(Map<String, dynamic> json) {
    return EndingListItemDto(
        json["endingName"],
        json["endingUrl"],
        json["endingImageUrl"],
        json["endingLength"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "endingName": endingName,
      "endingUrl": endingUrl,
      "endingImageUrl": endingImageUrl,
      "endingLength": endingLength
    };
  }
}