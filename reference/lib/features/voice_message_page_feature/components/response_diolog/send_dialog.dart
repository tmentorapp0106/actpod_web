import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../components/center_dialog.dart';
import '../../../../dto/player_item_dto.dart';
import '../../../../dto/voice_message_dto.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/send_controller.dart';

class SendDialog extends ConsumerWidget {
  final SendController _sendController;
  final RecordController _recordController;
  final VoiceMessageDto _voiceMessageDto;
  final BuildContext _dialogContext;
  SendDialog(this._sendController, this._recordController, this._voiceMessageDto, this._dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "送出語音留言",
      content: "你的語音留言有可能出現在故事內容中，確認想要送出留言嗎？",
      leftButtonText: '取消',
      rightButtonText: "確認",
      leftButtonFunction: () {
        Navigator.of(_dialogContext).pop();
      },
      rightButtonFunction: () {
        Navigator.of(_dialogContext).pop();
        _sendController.sendResponse(_recordController.audioFilePath!, _voiceMessageDto)
        .then((responseDto){
          Navigator.of(_dialogContext).pop(responseDto);
        });
      },
    );
  }
}