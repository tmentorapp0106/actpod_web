import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';

import '../../../../config/color.dart';
import '../../providers.dart';

class PlayButton extends ConsumerWidget {
  RecordController recordController;

  PlayButton(this.recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(sendVoiceMessageStatusProvider);
    return GestureDetector(
      onTap: () {
        if(messageRecordingStatus == "playing") {
          recordController.pauseAudio();
        } else if(messageRecordingStatus == "pausing") {
          recordController.restartAudio();
        } else {
          recordController.playAudio();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
            border: Border.all(
          )
        ),
        child: Icon(
          messageRecordingStatus == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: ConfigColor.textColorDefault,
          size: 65.w
        )
      )
    );
  }

}