import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/dto/interactive_content_dto.dart';
import 'package:flutter_riverpod/legacy.dart';

final pagePositionProvider = StateProvider.autoDispose<int>((ref) => 0);

final totalLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final playTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final playerStatusProvider = StateProvider.autoDispose<String>((ref) => "paused"); // paused, playing


final preMessageRecordStatusProvider = StateProvider.autoDispose<String>((ref) => "pending"); // pending, recording, recorded, playing, pausing, uploading
final preMessagePlayingTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final preMessageRecordTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final preMessageLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final afterMessageRecordStatusProvider = StateProvider.autoDispose<String>((ref) => "pending"); // pending, recording, recorded, playing, pausing, uploading
final afterMessagePlayingTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final afterMessageRecordTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final afterMessageLengthProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final concatedMessageFilePath = StateProvider<String?>((ref) => null);