import 'dart:io';

class UploadPreviewDto {
  String collaboratorId;
  String collaboratorName;
  String collaboratorAvatarUrl;
  List<File>? storyImages;
  String storyName;
  String channelName;
  String channelImageUrl;
  String spaceName;
  String storyDescription;
  String boardId;
  Duration storyLength;
  bool isPremium;

  UploadPreviewDto(this.collaboratorId, this.collaboratorName, this.collaboratorAvatarUrl, this.storyImages, this.storyName, this.channelName, this.channelImageUrl, this.spaceName, this.storyDescription, this.boardId, this.storyLength, this.isPremium);
}