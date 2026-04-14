enum MicPermissionAction {
  granted,
  revoke,
  updateMember
}

enum LiveKitAction {
  start,
  stop
}

class LiveKitCmd {
  LiveKitAction action;
  String param;

  LiveKitCmd(this.action, this.param);
}

class WsMessageDto {
  String cmd;
  String roomId;
  String storyId;
  String content;
  String from;
  String to;
  List<String> params;

  WsMessageDto(
    this.cmd,
    this.roomId,
    this.storyId,
    this.content,
    this.from,
    this.to,
    this.params
  );

  factory WsMessageDto.fromJson(Map<String, dynamic> json) {
    return WsMessageDto(
      (json['cmd'] ?? '') as String,
      (json['roomId'] ?? '') as String,
      (json['storyId'] ?? '') as String,
      (json['content'] ?? '') as String,
      (json['from'] ?? '') as String,
      (json['to'] ?? '') as String,
      (json['params'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cmd': cmd,
      'roomId': roomId,
      'storyId': storyId,
      'content': content,
      'from': from,
      'to': to,
      'params': params,
    };
  }
}