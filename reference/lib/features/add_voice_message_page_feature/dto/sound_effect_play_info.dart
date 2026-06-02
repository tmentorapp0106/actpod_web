class SoundEffectPlayInfo {
  Duration start;
  Duration end;

  SoundEffectPlayInfo(this.start, this.end);

  bool checkReached(Duration duration) {
    return duration >= start && duration <= end;
  }

  Duration getDuration() {
    return end - start;
  }

  bool checkEnded(Duration duration) {
    return duration > end;
  }
}