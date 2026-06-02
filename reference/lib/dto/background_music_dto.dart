class BackgroundMusicDto {
  String url;
  String name;
  int startMilliSec;
  int endMilliSec;

  BackgroundMusicDto({
    required this.url,
    required this.name,
    required this.startMilliSec,
    required this.endMilliSec
  });

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "name": name,
      "startMilliSec": startMilliSec,
      "endMilliSec": endMilliSec,
    };
  }

  bool checkReached(Duration duration) {
    return duration.inMilliseconds >= startMilliSec && duration.inMilliseconds <= endMilliSec;
  }

  Duration getDuration() {
    return Duration(milliseconds: endMilliSec) - Duration(milliseconds: startMilliSec);
  }

  bool checkEnded(Duration duration) {
    return duration > Duration(milliseconds: endMilliSec);
  }
}