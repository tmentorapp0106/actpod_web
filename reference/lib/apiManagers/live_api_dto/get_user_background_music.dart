import '../../dto/live_room_background_music_dto.dart';

class GetUserBackgroundMusic {
  String code;
  String message;
  List<LiveRoomBackgroundMusicDto> backgroundMusics;

  GetUserBackgroundMusic(this.code, this.message, this.backgroundMusics);

  factory GetUserBackgroundMusic.fromJson(Map<String, dynamic> json) {
    return GetUserBackgroundMusic(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      ((json['data'] ?? []) as List)
          .map((e) => LiveRoomBackgroundMusicDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}