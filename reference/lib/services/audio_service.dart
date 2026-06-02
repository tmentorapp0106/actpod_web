import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/ws_service.dart';

import '../utils/audio_fix_utils.dart';

Future<ActPodAudioHandler> initAudioService() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.speech());

  return await AudioService.init(
    builder: () => ActPodAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationIcon: 'drawable/ic_stat_actpod',
      androidResumeOnClick: true,
      androidStopForegroundOnPause: false,
      fastForwardInterval: Duration(seconds: 15),
      rewindInterval: Duration(seconds: 15)
    ),
  );
}

class ActPodAudioHandler extends BaseAudioHandler
    with QueueHandler, // mix in default queue callback implementations
        SeekHandler { // mix in default seek callback implementations
  WsService? liveRoomWs;
  final contentPlayer = AudioPlayer();
  WsService wsService = WsService(wsBaseUrl: dotenv.env["WS_SERVER_URL"]?? "");
  bool showControls = true;
  final _playlist = ConcatenatingAudioSource(children: [], useLazyPreparation: true);

  ActPodAudioHandler() {
    loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForCurrentSongIndexChanges();
    _listenForDurationChanges();
    _listenForPositionChanges();
  }

  Future<void> loadEmptyPlaylist() async {
    try {
      _playlist.clear();
      await contentPlayer.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void setShowSeekControls(bool value) {
    showControls = value;
    _broadcastPlaybackState();
  }

  Future<void> replaceQueueAndPlay({
    required List<MediaItem> mediaItems,
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
    bool autoPlay = true,
    AudioServiceRepeatMode repeatMode = AudioServiceRepeatMode.none
  }) async {
    if (mediaItems.isEmpty) return;

    final safeIndex = initialIndex.clamp(0, mediaItems.length - 1);

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    await AudioFixUtil.resetToMediaVolume();
    await updateQueue(mediaItems);
    await setRepeatMode(repeatMode);
    await skipToQueueItem(safeIndex);
    await seek(initialPosition);

    mediaItem.add(mediaItems[safeIndex]);

    if (autoPlay) {
      await play();
    } else {
      await pause();
    }
  }

  void _listenForCurrentSongIndexChanges() {
    contentPlayer.currentIndexStream.listen((index) async {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
    });
  }

  void _listenForPositionChanges() {
    contentPlayer.positionStream.listen((position) async {
      final duration = contentPlayer.duration;
      if (duration != null) {
        final remaining = duration - position;
      }
    });
  }

  void _listenForDurationChanges() {
    contentPlayer.durationStream.listen((duration) {

      final index = contentPlayer.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    contentPlayer.playbackEventStream.listen((PlaybackEvent event) {
      _broadcastPlaybackState(event);
    });
  }

  void _broadcastPlaybackState([PlaybackEvent? event]) {
    final playing = contentPlayer.playing;

    List<MediaControl> controls = showControls? <MediaControl>[
      MediaControl.rewind,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.fastForward,
    ] : [];

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: showControls? const {
          MediaAction.seek,
        } : const {},
        androidCompactActionIndices: showControls? List.generate(
          controls.length,
          (index) => index,
        ) : [],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[contentPlayer.processingState]!,
        playing: playing,
        updatePosition: contentPlayer.position,
        bufferedPosition: contentPlayer.bufferedPosition,
        speed: contentPlayer.speed,
        queueIndex: event?.currentIndex ?? contentPlayer.currentIndex,
      ),
    );
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override updateQueue(List<MediaItem> newQueue) async {
    // manage Just Audio
    final audioSource = newQueue.map(_createAudioSource);
    await _playlist.clear();
    await _playlist.addAll(audioSource.toList());

    // notify system
    queue.value.clear();
    final updatedQueue = queue.value..addAll(newQueue);
    queue.add(updatedQueue);
  }

  @override skipToQueueItem(int index) async {
    // await contentPlayer.setAudioSource(_playlist, initialIndex: index);
    // queue.skip(index);
    final items = queue.value;
    if (items.isEmpty) return;
    if (index < 0 || index >= items.length) return;

    await contentPlayer.seek(Duration.zero, index: index);
    mediaItem.add(items[index]);
  }

  Future<void> playFromIndex(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;
    await contentPlayer.seek(Duration.zero, index: index);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  @override
  Future<void> play() async {
    await contentPlayer.play();
  }

  @override
  Future<void> pause() async {
    await contentPlayer.pause();
  }
  @override
  Future<void> stop() async {
    contentPlayer.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await contentPlayer.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await contentPlayer.setSpeed(speed);
  }

  @override
  Future<void> skipToNext() async {
    await contentPlayer.seekToNext();
  }
  @override
  Future<void> skipToPrevious() async {
    await contentPlayer.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        contentPlayer.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        contentPlayer.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        contentPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  Duration getCurrentDuration() {
    return contentPlayer.position;
  }

  double getSpeed() {
    return contentPlayer.speed;
  }

  bool isPlaying() {
    return contentPlayer.playing;
  }

  String? getCurrentMediaItemId() {
    return mediaItem.value?.id;
  }
}
