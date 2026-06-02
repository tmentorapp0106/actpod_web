import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class ExtractedPreviewPlayerTimerController {
  WidgetRef _ref;
  bool _keepTrack = true;
  List<Duration> soundPositions = [];
  Duration skipLength = Duration.zero;
  Duration storyPosition = Duration.zero;
  int lastAddSkipLengthIndex = -1;

  ExtractedPreviewPlayerTimerController(this._ref);

  void stopTrackingProgress() {
    _keepTrack = false;
  }

  void startTrackingProgress() {
    _keepTrack = true;
    _aggregatePlayerTimer();
  }

  void setAllTrackPositionsToZero() {
    List<Duration> newSoundPositions = List.generate(soundPositions.length, (i) {
      return Duration(milliseconds: 0);
    });
    soundPositions = newSoundPositions;
    skipLength = Duration.zero;
  }

  void addSkipLength(int index, Duration duration) {
    skipLength += duration;
  }

  void changeStoryPosition(Duration duration) {
    storyPosition = duration;
    _aggregatePlayerTimer();
  }

  void insertBlockPosition(int index, Duration duration) {
    soundPositions.insert(index, Duration(milliseconds: duration.inMilliseconds));
  }

  void changeStoryTimer(Duration duration) {
    storyPosition = duration;
    _aggregatePlayerTimer();
  }

  void changeBlockPosition(int index, Duration duration) {
    List<Duration> newSoundPositions = List.generate(soundPositions.length, (i) {
      if(i == index) {
        return Duration(milliseconds: duration.inMilliseconds);
      }
      return Duration(milliseconds: soundPositions[i].inMilliseconds);
    });
    soundPositions = newSoundPositions;
    _aggregatePlayerTimer();
  }

  Duration getCursor() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    return cursor;
  }

  void _aggregatePlayerTimer() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    if(_keepTrack) {
      _ref.watch(extractedPreviewPlayTimerProvider.notifier).state = cursor - _ref.watch(extractedPreviewStartPositionProvider);
    }
  }
}