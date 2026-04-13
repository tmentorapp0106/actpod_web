class LivekitStatusDto {
  bool started;
  List<String> onMicMembers;
  String backgroundMusicUrl;

  LivekitStatusDto({
    required this.started,
    required this.onMicMembers,
    required this.backgroundMusicUrl
  });

  factory LivekitStatusDto.fromJson(Map<String, dynamic> json) {
    return LivekitStatusDto(
      started: json['started'] as bool,
      onMicMembers: (json['onMicMembers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      backgroundMusicUrl: json['backgroundMusicUrl'] as String,
    );
  }
}