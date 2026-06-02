class SpaceInfoDto {
  String spaceId;
  String name;
  String description;
  String imageUrl;
  int storyCount;

  SpaceInfoDto(this.spaceId, this.name, this.description, this.imageUrl, this.storyCount);

  factory SpaceInfoDto.fromJson(Map<String, dynamic> json) {
    return SpaceInfoDto(
        json["spaceId"],
        json["name"],
        json["description"],
        json["imageUrl"],
        json["storyCount"]
    );
  }

  Map toJson() => {
    'spaceId': spaceId,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    "storyCount": storyCount
  };
}