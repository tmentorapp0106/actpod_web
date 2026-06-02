import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';

import '../../apiManagers/story_api_dto/get_one_story_res.dart';

final voiceMessageWidgetKey = StateProvider<List<GlobalKey>>((ref) => []);

final voiceMessageListProvider = StateProvider<List<VoiceMessageDto>>((ref) => []);
final storyInfoProvider = StateProvider.autoDispose<GetOneStoryResItem?>((ref) => null);

final responseStatusProvider = StateProvider.autoDispose<String>((ref) => "pending"); // pending, recording, recorded, playing, pausing, uploading
final responseLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final responseRecordTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final responsePlayingTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final focusAudioIdProvider = StateProvider.autoDispose<String?>((ref) => null);
final messagePlayerProgressProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final messagePlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop"); // loading, pausing, playing, stop

final storyPlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop"); // pausing, playing, stop
final storyPlayerProgressProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final storyLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final addVoiceMessagePlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop"); // pausing, playing, stop
final addVoiceMessagePlayerProgressProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final addVoiceMessageLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final donataAmountProvider = StateProvider<int>((ref) => 0);

final likeStatusProvider = StateProvider.autoDispose<bool>((ref) => false);
final likesCountProvider = StateProvider.autoDispose<int>((ref) => 0);

final changeVoiceProvider = StateProvider<bool>((ref) => false);

final transcribingVoiceMessageIdProvider = StateProvider.autoDispose<String?>((ref) => null);