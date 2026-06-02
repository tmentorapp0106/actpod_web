

import '../../dto/space_story_dto.dart';

class GetSpaceStoriesRes {
  String code;
  String message;
  List<SpaceStoryDto> spacesInfo;

  GetSpaceStoriesRes(this.code, this.message, this.spacesInfo);
  
  factory GetSpaceStoriesRes.fromJson(Map<String, dynamic> json) {
    return GetSpaceStoriesRes(
      json["code"],
      json["message"],
      json["data"] == null? [] : json["data"].map<SpaceStoryDto>((json) => SpaceStoryDto.fromJson(json)).toList()
    );
  }
}