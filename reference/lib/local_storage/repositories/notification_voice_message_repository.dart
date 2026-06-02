import 'package:quick_share_app/dto/notification_voice_message_dto.dart';

import '../../main.dart';
import '../../objectbox.g.dart';

final NotificationVoiceMessageRepository notificationVoiceMessageRepository  = NotificationVoiceMessageRepository(store);

class NotificationVoiceMessageRepository {
  final Store _store;
  Box<NotificationVoiceMessageDto>? _notificationVoiceMessageBox;

  NotificationVoiceMessageRepository(this._store) {
    _notificationVoiceMessageBox = Box<NotificationVoiceMessageDto>(_store);
  }

  int? insertCollection(NotificationVoiceMessageDto messageDto) {
    return _notificationVoiceMessageBox?.put(messageDto);
  }

  List<int>? insertManyMessages(List<NotificationVoiceMessageDto> messageList) {
    return _notificationVoiceMessageBox?.putMany(messageList);
  }

  List<NotificationVoiceMessageDto>? getAllVoiceMessagesByUserId(String userId) {
    Query<NotificationVoiceMessageDto>? query = _notificationVoiceMessageBox?.query(
        NotificationVoiceMessageDto_.storyOwnerId.equals(userId)
        .or(NotificationVoiceMessageDto_.createdByUserId.equals(userId)))
        .order(NotificationVoiceMessageDto_.voiceMessageId, flags: Order.descending).build();
    return query?.find();
  }

  List<NotificationVoiceMessageDto>? getAllVoiceMessages() {
    final query = _notificationVoiceMessageBox?.query().order(NotificationVoiceMessageDto_.voiceMessageId, flags: Order.descending).build();
    return query?.find();
  }

  int? removeAllMessages() {
    return _notificationVoiceMessageBox?.removeAll();
  }

  int? removeAllVoiceMessagesByUserId(String userId) {
    Query<NotificationVoiceMessageDto>? query = _notificationVoiceMessageBox?.query(
        NotificationVoiceMessageDto_.storyOwnerId.equals(userId)
            .or(NotificationVoiceMessageDto_.createdByUserId.equals(userId)))
        .order(NotificationVoiceMessageDto_.editTime, flags: Order.descending).build();
    return query?.remove();
  }

  void updateVoiceMessageAppendStatus(String voiceMessageId, String replyAudioContentUrl, bool appendStatus) {
    final query = _notificationVoiceMessageBox?.query(NotificationVoiceMessageDto_.voiceMessageId.equals(voiceMessageId)).build();
    NotificationVoiceMessageDto? voiceMessage = query?.findFirst();
    if(voiceMessage != null) {
      voiceMessage.append = appendStatus;
      voiceMessage.replyAudioContentUrl = replyAudioContentUrl;
      _notificationVoiceMessageBox?.put(voiceMessage);
    }
  }
}