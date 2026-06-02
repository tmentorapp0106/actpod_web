class ChatMessageDto {
  String userId;
  String nickname;
  String avatarUrl;
  String content;
  String type; // sticker, handsUp
  String? stickerUrl;
  int? donateAmount;

  ChatMessageDto({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.content,
    required this.type,
    this.stickerUrl,
    this.donateAmount
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final params = json['params'] as List<dynamic>?;

    final isSticker = params != null &&
        params.isNotEmpty &&
        params[0] == 'sticker';

    final String? stickerUrl =
    isSticker && params.length > 1 ? params[1]?.toString() : null;

    final int? donateAmount =
    isSticker && params.length > 2 ? int.tryParse(params[2].toString()) : null;

    return ChatMessageDto(
      userId: (json['userId'] ?? '') as String,
      nickname: (json['nickname'] ?? '') as String,
      avatarUrl: (json['userAvatarUrl'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      type: isSticker ? 'sticker' : '',
      stickerUrl: stickerUrl,
      donateAmount: donateAmount,
    );
  }
}