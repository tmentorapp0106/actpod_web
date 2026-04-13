class RoomBulletinDto {
  String roomId;
  String bulletinId;
  String title;
  String content;
  String imageUrl;
  List<String> params;

  RoomBulletinDto({
    required this.roomId,
    required this.bulletinId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.params
  });

  factory RoomBulletinDto.fromJson(Map<String, dynamic> json) {
    return RoomBulletinDto(
      roomId: (json['roomId'] ?? '').toString(),
      bulletinId: (json['bulletinId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          <String>[],
    );
  }
}