class PodcastStoreDto {
  String storeId;
  String userId;
  String name;
  String description;
  String storeImageUrl;
  String instagramUrl;
  String facebookUrl;
  String threadsUrl;
  String youtubeUrl;
  List<PodcastStoreLinkDto> links;
  bool archive;
  DateTime createTime;
  DateTime updateTime;

  PodcastStoreDto(
      this.storeId,
      this.userId,
      this.name,
      this.description,
      this.storeImageUrl,
      this.instagramUrl,
      this.facebookUrl,
      this.threadsUrl,
      this.youtubeUrl,
      this.links,
      this.archive,
      this.createTime,
      this.updateTime,
      );

  factory PodcastStoreDto.fromJson(Map<String, dynamic> json) {
    return PodcastStoreDto(
      (json['storeId'] ?? '') as String,
      (json['userId'] ?? '') as String,
      (json['name'] ?? '') as String,
      (json['description'] ?? '') as String,
      (json['storeImageUrl'] ?? '') as String,
      (json['instagramUrl'] ?? '') as String,
      (json['facebookUrl'] ?? '') as String,
      (json['threadsUrl'] ?? '') as String,
      (json['youtubeUrl'] ?? '') as String,
      (json['links'] as List<dynamic>? ?? const [])
          .map((e) => PodcastStoreLinkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['archive'] ?? false) as bool,
      DateTime.tryParse((json['createTime'] ?? '') as String) ?? DateTime.fromMillisecondsSinceEpoch(0),
      DateTime.tryParse((json['updateTime'] ?? '') as String) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class PodcastStoreLinkDto {
  String imageUrl;
  String url;

  PodcastStoreLinkDto(
      this.imageUrl,
      this.url,
      );

  factory PodcastStoreLinkDto.fromJson(Map<String, dynamic> json) {
    return PodcastStoreLinkDto(
      (json['imageUrl'] ?? '') as String,
      (json['url'] ?? '') as String,
    );
  }
}