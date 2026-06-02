class AnnouncementDto {
  String title;
  String description;
  String bannerImageUrl;
  String announcementImageUrl;

  AnnouncementDto(this.title, this.description, this.bannerImageUrl, this.announcementImageUrl);

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    return AnnouncementDto(
      json["title"],
      json["description"],
      json["bannerImageUrl"],
      json["announcementImageUrl"]
    );
  }
}