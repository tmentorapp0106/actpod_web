import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/hold_to_record_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';
import 'package:vibration/vibration.dart';

import '../../../../components/long_press_detector.dart';
import '../../../../config/color.dart';

class RecordButton extends ConsumerWidget {
  final RecordController recordController;

  RecordButton(this.recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(sendVoiceMessageStatusProvider);

    return HoldToRecordButton(
      onStartRecording: () async {
        ref.watch(sendVoiceMessageStatusProvider.notifier).state = "recording";
        bool hasVibrator = await Vibration.hasVibrator();
        await recordController.startRecord();
        if (hasVibrator) {
          await Vibration.vibrate(duration: 20);
        }
      },
      onStopRecording: ({bool canceled = false}) async {
        if(messageRecordingStatus != "recording") {
          return;
        }
        if (canceled) {
          recordController.stopRecord();
          return;
        } else {
          recordController.stopRecord();
          return;
        }
      },
    );
  }
}