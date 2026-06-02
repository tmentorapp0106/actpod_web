import '../../dto/announcement_dto.dart';

class GetActiveAnnouncementRes {
  String code;
  String message;
  List<AnnouncementDto> announcements;

  GetActiveAnnouncementRes(this.code, this.message, this.announcements);

  factory GetActiveAnnouncementRes.fromJson(Map<String, dynamic> json) {
    return GetActiveAnnouncementRes(json["code"], json["message"], (json["data"] as List?)
        ?.map<AnnouncementDto>((json) => AnnouncementDto.fromJson(json))
        .toList() ?? []);
  }
}