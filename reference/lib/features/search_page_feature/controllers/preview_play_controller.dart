import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/search_stories_res.dart';
import '../providers.dart';

class PreviewPlayController {
  final WidgetRef _ref;
  final AudioPlayer player = AudioPlayer();
  StreamSubscription<ProcessingState>? stateStreamSub;
  bool initFinish = false;

  PreviewPlayController(this._ref);

  Future<void> dispose() async {
    await player.stop();
    player.dispose();
    stateStreamSub?.cancel();
  }

  Future<void> init() async {
    _ref.watch(searchPreviewIndexProvider.notifier).state = -1;
    List<SearchStoriesResItem>? playItems = _ref.watch(searchStoriesItemListProvider);
    if(playItems == null || playItems.isEmpty) {
      return;
    }
    stateStreamSub = player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        player.pause();
        _ref.watch(searchPreviewIndexProvider.notifier).state = null;
        _ref.watch(searchPreviewPlayStatusProvider.notifier).state = "paused";
      }
    });
  }

  Future<void> playPause(int index) async {
    if(_ref.watch(searchPreviewIndexProvider) == index && _ref.watch(searchPreviewPlayStatusProvider) == "playing") {
      player.pause();
      _ref.watch(searchPreviewIndexProvider.notifier).state = null;
      _ref.watch(searchPreviewPlayStatusProvider.notifier).state = "paused";
    } else {
      List<SearchStoriesResItem>? playItems = _ref.watch(searchStoriesItemListProvider);
      _ref.watch(searchPreviewPlayStatusProvider.notifier).state = "playing";
      _ref.watch(searchPreviewIndexProvider.notifier).state = index;
      await player.setAudioSource(AudioSource.uri(Uri.parse(playItems![index].previewUrl)));
      player.play();
    }
  }

  void pausePreview() {
    player.pause();
    _ref.watch(searchPreviewIndexProvider.notifier).state = null;
    _ref.watch(searchPreviewPlayStatusProvider.notifier).state = "paused";
  }
}