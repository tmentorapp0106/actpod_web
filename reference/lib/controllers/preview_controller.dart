import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/providers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final previewPlayerController = PreviewPlayController();

class PreviewPlayController {
  AudioPlayer? player;
  StreamSubscription<ProcessingState>? stateStreamSub;

  PreviewPlayController();

  Future<void> dispose() async {
    await player?.stop();
    player?.dispose();
    stateStreamSub?.cancel();
  }

  Future<void> reset(WidgetRef ref, PreviewPage page) async {
    ref.watch(previewPlayIndexProvider.notifier).state = null;
    ref.watch(previewPlayStatusProvider.notifier).state = PreviewPlayStatus.paused;
    ref.watch(currentPreviewPageProvider.notifier).state = page;
  }

  Future<void> stop(WidgetRef ref, {required bool force}) async {
    WakelockPlus.disable();
    if(ref.watch(previewPlayStatusProvider) == PreviewPlayStatus.loading && !force) {
      return;
    }
    await player?.stop();
    player?.dispose();
    player = null;
    ref.watch(previewPlayIndexProvider.notifier).state = null;
    ref.watch(previewPlayStatusProvider.notifier).state = PreviewPlayStatus.paused;
  }

  Future<void> previewPlayFunction(WidgetRef ref, int index, String previewUrl, PreviewPage page) async {
    if(ref.watch(previewPlayIndexProvider) == index && ref.watch(previewPlayStatusProvider) == PreviewPlayStatus.playing) {
      stop(ref, force: true);
    } else {
      playAudio(ref, previewUrl, index, page);
    }
  }

  Future<void> playAudio(WidgetRef ref, String url, int index, PreviewPage page) async {
    WakelockPlus.enable();
    await stateStreamSub?.cancel();
    stateStreamSub = null;
    WakelockPlus.disable();
    await player?.stop();
    player?.dispose();

    player = AudioPlayer();
    stateStreamSub = player!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        player?.stop();
        ref.watch(previewPlayIndexProvider.notifier).state = null;
        ref.watch(previewPlayStatusProvider.notifier).state = PreviewPlayStatus.paused;
      }
    });
    ref.watch(previewPlayStatusProvider.notifier).state = PreviewPlayStatus.loading;
    ref.watch(previewPlayIndexProvider.notifier).state = index;
    await player?.setAudioSource(AudioSource.uri(Uri.parse(url)));
    if (page == ref.watch(currentPreviewPageProvider)) {
      ref.watch(previewPlayStatusProvider.notifier).state = PreviewPlayStatus.playing;
      await player?.play();
    }
  }
}