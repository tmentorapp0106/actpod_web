import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/const/const.dart';

import '../providers.dart';

class PreviewPlayerTimerController {
  WidgetRef _ref;
  final ScrollController _previewBarScrollController;
  bool _keepTrack = true;
  List<Duration> soundPositions = [];
  Duration skipLength = Duration.zero;
  Duration storyPosition = Duration.zero;
  int lastAddSkipLengthIndex = -1;

  PreviewPlayerTimerController(this._ref, this._previewBarScrollController);

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

  void changeTimer() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    _ref.watch(previewPageStoryPlayTimerProvider.notifier).state = cursor;
  }

  Duration getCursor() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    return cursor;
  }

  void changeStoryPosition(Duration duration) {
    storyPosition = duration;
    _aggregatePlayerTimer();
  }

  void _aggregatePlayerTimer() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    if(_keepTrack) {
      _ref.watch(previewPageStoryPlayTimerProvider.notifier).state = cursor;
      _previewBarScrollController.jumpTo(cursor.inMilliseconds / extractPreviewScale);
    }
  }
}