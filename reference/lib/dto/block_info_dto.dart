

class BlockInfoDto {
  Duration from;
  Duration to;
  Duration position;
  int soundIndex;
  Duration length;
  double volume;
  String url;
  String name;
  List<double> waveformData;
  Duration skip; // for cut
  String type; // sound, story
  String soundType; // soundEffect, music

  BlockInfoDto(
  {required this.from,
    required this.to,
    required this.position,
    required this.soundIndex,
    required this.length,
    required this.volume,
    required this.url,
    required this.name,
    required this.waveformData,
    required this.skip,
    required this.type,
    required this.soundType,
  });

  factory BlockInfoDto.fromJson(Map<String, dynamic> json) {
    return BlockInfoDto(
      from: Duration(milliseconds: json['fromMilliSec']),
      to: Duration(milliseconds: json['toMilliSec']),
      position: Duration(milliseconds: json['positionMilliSec']),
      soundIndex: json['soundIndex'],
      length: Duration(milliseconds: json['lengthMilliSec']),
      volume: (json['volume'] as num).toDouble(), // Ensures it's a double
      url: json['url'],
      name: json['name'],
      waveformData: (json['waveformData'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      skip: Duration(milliseconds: json['skipMilliSec']),
      type: json['type'],
      soundType: json['soundType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromMilliSec': from.inMilliseconds,
      'toMilliSec': to.inMilliseconds,
      'positionMilliSec': position.inMilliseconds,
      'soundIndex': soundIndex,
      'lengthMilliSec': length.inMilliseconds,
      'name': name,
      'waveformData': waveformData,
      'skipMilliSec': skip.inMilliseconds,
      'volume': volume,
      'url': url,
      'type': type,
      'soundType': soundType
    };
  }

  // Clone method
  BlockInfoDto clone() {
    return BlockInfoDto(
      from: Duration(milliseconds: from.inMilliseconds),
      to: Duration(milliseconds: to.inMilliseconds),
      position: Duration(milliseconds: position.inMilliseconds),
      soundIndex: soundIndex,
      length: Duration(milliseconds: length.inMilliseconds),
      volume: volume,
      url: url,
      name: name,
      waveformData: List<double>.from(waveformData), // Deep copy of the list
      skip: Duration(milliseconds: skip.inMilliseconds),
      type: type,
      soundType: soundType,
    );
  }
}