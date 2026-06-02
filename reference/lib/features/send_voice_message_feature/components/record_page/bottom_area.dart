import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/dto/record_item_dto.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/finish_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/play_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/record_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/remove_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';

import '../../controllers/send_controller.dart';
import '../../providers.dart';

class SendMessageBottomArea extends ConsumerWidget {
  final RecordController recordController;
  final SendController sendController;
  final BuildContext dialogContext;
  final PlayerItemDto playerItemDto;


  SendMessageBottomArea(this.recordController, this.sendController, this.dialogContext, this.playerItemDto);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(sendVoiceMessageStatusProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 55.w,
            child: messageRecordingStatus == "recorded" || messageRecordingStatus == "pausing" || messageRecordingStatus == "playing"? RemoveButton(recordController) : const SizedBox.shrink()
        ),
        messageRecordingStatus == "recorded" || messageRecordingStatus == "pausing" || messageRecordingStatus == "playing"? SizedBox(width: 10.w,) : SizedBox(width: 20.w,),
        messageRecordingStatus == "pending" || messageRecordingStatus == "recording"? RecordButton(recordController) : PlayButton(recordController),
        messageRecordingStatus == "recorded" || messageRecordingStatus == "pausing" || messageRecordingStatus == "playing"? SizedBox(width: 10.w,) : SizedBox(width: 20.w,),
        SizedBox(
          width: 55.w,
          child: messageRecordingStatus == "recorded" || messageRecordingStatus == "pausing" || messageRecordingStatus == "playing"? FinishButton(playerItemDto, sendController, recordController, dialogContext) : SizedBox(width: 20.w,),
        )
      ],
    );
  }
}