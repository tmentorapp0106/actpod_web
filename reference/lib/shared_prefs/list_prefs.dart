import 'dart:convert';

import 'package:quick_share_app/dto/sound_effect_list_item_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/backgournd_music_list_item_dto.dart';

class ListPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool?> setBackgroundMusicList(List<BackgroundMusicListItemDto> backgroundMusicList) async {
    return await prefs?.setStringList("backgroundMusicList", backgroundMusicList.map((backgroundMusic) => jsonEncode(backgroundMusic.toJson())).toList());
  }

  static List<BackgroundMusicListItemDto>? getBackgroundMusicList() {
    List<String>? backgroundStrList = prefs?.getStringList("backgroundMusicList");
    if (backgroundStrList == null) {
      return null;
    }

    return backgroundStrList.map((backgroundMusicStr) => BackgroundMusicListItemDto.fromJson(jsonDecode(backgroundMusicStr))).toList();
  }

  static Future<bool?> setSoundEffectList(List<SoundEffectListItemDto> soundEffectList) async {
    return await prefs?.setStringList("soundEffectList", soundEffectList.map((soundEffect) => jsonEncode(soundEffect.toJson())).toList());
  }

  static List<SoundEffectListItemDto>? getSoundEffectList() {
    List<String>? soundEffectStrList = prefs?.getStringList("soundEffectList");
    if (soundEffectStrList == null) {
      return null;
    }

    return soundEffectStrList.map((soundEffectStr) => SoundEffectListItemDto.fromJson(jsonDecode(soundEffectStr))).toList();
  }
}