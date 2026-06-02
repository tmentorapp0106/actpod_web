import 'package:flutter_riverpod/legacy.dart';

import '../../dto/voice_message_notice_dto.dart';

final storyVoiceMessageNoticeListProvider = StateProvider<List<VoiceMessageNoticeDto>>((ref) => []);
final listenedVoiceMessageNoticeListProvider = StateProvider<List<VoiceMessageNoticeDto>>((ref) => []);


final senderPlayerBarProgressProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final senderPlayerBarAudioLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final senderPlayerBarAudioRemainedLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final senderPlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop");// "playing", "pause", "stop"

final responsePlayerBarProgressProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final responsePlayerBarAudioLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final responsePlayerBarAudioRemainedLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final responsePlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop");// "playing", "pause", "stop"


final playerLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final notificationLoadingStatus = StateProvider.autoDispose<bool>((ref) => false);