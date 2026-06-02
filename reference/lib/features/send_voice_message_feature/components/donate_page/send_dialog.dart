import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../components/center_dialog.dart';
import '../../../../dto/player_item_dto.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/send_controller.dart';

class SendDialog extends ConsumerWidget {
  final SendController _sendController;
  final RecordController _recordController;
  final PlayerItemDto _playerItemDto;
  final BuildContext _dialogContext;
  SendDialog(this._sendController, this._recordController, this._playerItemDto, this._dialogContext);

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
        _sendController.sendVoiceMessage(
          _recordController.audioFilePath!,
          _playerItemDto.storyId,
          10,
          ref.watch(acceptAddProvider)? "accept" : "reject"
        )
            .then((value){
          Navigator.of(_dialogContext).pop();
        });
      },
    );
  }
}