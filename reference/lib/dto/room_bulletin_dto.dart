class RoomBulletinDto {
  String roomId;
  String bulletinId;
  String title;
  String content;
  List<String> imageUrls;
  List<String> params;

  RoomBulletinDto({
    required this.roomId,
    required this.bulletinId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.params
  });

  factory RoomBulletinDto.fromJson(Map<String, dynamic> json) {
    return RoomBulletinDto(
      roomId: (json['roomId'] ?? '').toString(),
      bulletinId: (json['bulletinId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList() ??
          <String>[],
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          <String>[],
    );
  }
}