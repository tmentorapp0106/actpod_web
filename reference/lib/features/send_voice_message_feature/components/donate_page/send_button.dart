import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../../../dto/player_item_dto.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/send_controller.dart';
import '../../providers.dart';

class SendButton extends ConsumerWidget {
  final SendController _sendController;
  final RecordController _recordController;
  final PlayerItemDto _playerItemDto;
  final BuildContext dialogContext;

  SendButton(this._sendController, this._recordController, this._playerItemDto, this.dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await _sendController.sendVoiceMessage(
          _recordController.audioFilePath!,
          _playerItemDto.storyId,
          ref.watch(donateAmountProvider),
          ref.watch(acceptAddProvider)? "accept" : "reject"
        );
        
        if(dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      },
      child: Container(
        width: 250.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: ConfigColor.primaryDefault,
          borderRadius: BorderRadius.circular(20.w)
        ),
        child: Center(
          child: Text(
            "使用並傳送",
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.black
            ),
          )
        ),
      ),
    );
  }
}