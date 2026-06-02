import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final noisePreviewProcessProvider = StateProvider<String?>((ref) => null); // processing, done
final noisePreviewPlayerStatusProvider = StateProvider<String>((ref) => "paused"); // playing, paused
final noisePreviewPlayerDurationProvider = StateProvider<Duration>((ref) => Duration.zero);
final noisePreviewPlayerLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final nrProvider = StateProvider<int>((ref) => 11); // 偏移 1
final nfProvider = StateProvider<int>((ref) => 38); // 偏移 -80