import '../../dto/sound_effect_list_item_dto.dart';

class GetSoundEffectListRes {
  String code;
  String message;
  List<SoundEffectListItemDto> data;

  GetSoundEffectListRes(this.code, this.message, this.data);

  factory GetSoundEffectListRes.fromJson(Map<String, dynamic> json) {
    return GetSoundEffectListRes(json["code"], json["message"], json["data"]?.map<SoundEffectListItemDto>((json) => SoundEffectListItemDto.fromJson(json)).toList());
  }
}