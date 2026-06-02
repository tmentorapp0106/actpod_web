import '../../dto/backgournd_music_list_item_dto.dart';

class GetBackgroundMusicListRes {
  String code;
  String message;
  List<BackgroundMusicListItemDto> data;

  GetBackgroundMusicListRes(this.code, this.message, this.data);

  factory GetBackgroundMusicListRes.fromJson(Map<String, dynamic> json) {
    return GetBackgroundMusicListRes(json["code"], json["message"], json["data"]?.map<BackgroundMusicListItemDto>((json) => BackgroundMusicListItemDto.fromJson(json)).toList());
  }
}