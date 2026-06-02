import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';

import '../providers.dart';

class EditTrimPlayerTimerController {
  WidgetRef _ref;
  final ScrollController storyBarScrollController;
  bool _keepTrack = true;
  List<Duration> soundPositions = [];
  Duration skipLength = Duration.zero;
  Duration storyPosition = Duration.zero;
  int lastAddSkipLengthIndex = -1;

  EditTrimPlayerTimerController(this._ref, this.storyBarScrollController);

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

  void changeStoryPosition(Duration duration) {
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

  void changeTimer() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    _ref.watch(playTimerProvider.notifier).state = cursor;
    if(_ref.watch(cutFromProvider) != null) {
      if(cursor < _ref.watch(cutFromProvider)!) {
        _ref.watch(cutFromProvider.notifier).state = null;
        _ref.watch(cutToProvider.notifier).state = null;
        return;
      }
      _ref.watch(cutToProvider.notifier).state = cursor;
    }
  }

  Future<void> resetCursor() async {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    _ref.watch(playTimerProvider.notifier).state = cursor;
    if (storyBarScrollController.hasClients) {
      await _waitNextFrame();
      storyBarScrollController.jumpTo(0);

      // ✅ Wait until the jump is actually rendered
      await _waitNextFrame();

      const Duration maxAnimatedDuration = Duration(minutes: 3);
      final double barScale = _ref.watch(barScaleProvider);
      final double targetScrollPosition = cursor.inMilliseconds / barScale;

      if (cursor > maxAnimatedDuration) {
        final jumpCursor = cursor - maxAnimatedDuration;
        final double jumpPosition = jumpCursor.inMilliseconds / barScale;

        storyBarScrollController.jumpTo(jumpPosition);

        // ✅ Again wait for frame after second jump
        await _waitNextFrame();

        final double distance = targetScrollPosition - jumpPosition;
        const double pixelsPerSecond = 4000;
        final double durationSeconds = distance / pixelsPerSecond;

        await storyBarScrollController.animateTo(
          targetScrollPosition,
          duration: Duration(milliseconds: (durationSeconds * 1000).round()),
          curve: Curves.easeIn,
        );

      } else {
        final double distance = (storyBarScrollController.position.pixels - targetScrollPosition).abs();
        const double pixelsPerSecond = 4000;
        final double durationSeconds = distance / pixelsPerSecond;

        await storyBarScrollController.animateTo(
          targetScrollPosition,
          duration: Duration(milliseconds: (durationSeconds * 1000).round()),
          curve: Curves.easeIn,
        );
      }
    }
    if(_ref.watch(cutFromProvider) != null) {
      _ref.watch(cutToProvider.notifier).state = cursor;
    }
  }

  Future<void> _waitNextFrame() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    await completer.future;
  }

  void _aggregatePlayerTimer() {
    Duration cursor = storyPosition;
    for(Duration trackPosition in soundPositions) {
      cursor += trackPosition;
    }
    cursor -= skipLength;
    if(_keepTrack) {
      _ref.watch(playTimerProvider.notifier).state = cursor;
      if(storyBarScrollController.hasClients) {
        storyBarScrollController.jumpTo(cursor.inMilliseconds / _ref.watch(barScaleProvider));
      }
      if(_ref.watch(cutFromProvider) != null) {
        _ref.watch(cutToProvider.notifier).state = cursor;
      }
    }
  }
}