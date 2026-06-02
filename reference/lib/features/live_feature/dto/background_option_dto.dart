import '../../../dto/live_room_background_music_dto.dart';

class BackgroundOptionDto {
  LiveRoomBackgroundMusicDto? musicDto;
  bool newMusic;
  bool stopMusic;


  BackgroundOptionDto({
    required this.musicDto,
    required this.newMusic,
    required this.stopMusic,
  });
}