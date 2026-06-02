class LiveRoomPriceRule {
  String ruleId;
  String roomId;
  String storyId;
  int notyetBoughtStory;
  int alreadyBoughtStory;

  LiveRoomPriceRule(
    this.ruleId,
    this.roomId,
    this.storyId,
    this.notyetBoughtStory,
    this.alreadyBoughtStory
  );

  factory LiveRoomPriceRule.fromJson(Map<String, dynamic> json) {
    return LiveRoomPriceRule(
      (json['ruleId'] ?? '') as String,
      (json['roomId'] ?? '') as String,
      (json['storyId'] ?? '') as String,
      (json['notyetBoughtStory'] ?? 0) as int,
      (json['alreadyBoughtStory'] ?? 0) as int,
    );
  }
}