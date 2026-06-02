import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(seconds: 10)
            : const Duration(hours: 2),
      ),
    );

    await _remoteConfig.setDefaults(const {
      'live_room_schedule': "https://story.actpodapp.com/live/schedule/schedule.png",
      'live_room_default_music': "https://story.actpodapp.com/live/background_music/default_background_music.mp3",
      'live_room_silence_music': "https://story.actpodapp.com/live/background_music/silent_5min.mp3"
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  String get liveRoomSchedule {
    return _remoteConfig.getString('live_room_schedule');
  }

  String get liveRoomDefaultMusic {
    return _remoteConfig.getString('live_room_default_music');
  }

  String get liveRoomSilenceMusic {
    return _remoteConfig.getString('live_room_silence_music');
  }
}