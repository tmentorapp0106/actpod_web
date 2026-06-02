import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';

import '../../../../components/hold_to_record_button.dart';
import '../../../../components/long_press_detector.dart';
import '../../../../config/color.dart';
import '../../controllers/record_controller.dart';
import '../../providers.dart';

class RecordButton extends ConsumerWidget {
  final RecordController recordController;

  RecordButton(this.recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(responseStatusProvider);

    return HoldToRecordButton(
      onStartRecording: () async {
        ref.watch(responseStatusProvider.notifier).state = "recording";
        bool hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          await Vibration.vibrate(duration: 50);
        }
        await Future.delayed(const Duration(milliseconds: 100));
        recordController.startRecord();
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTap: () async {
          if(messageRecordingStatus == "recording") {
            recordController.stopRecord();
            return;
          }

          bool? hasVibrator = await Vibration.hasVibrator();
          if (hasVibrator != null && hasVibrator) {
            await Vibration.vibrate(duration: 50);
          }
          recordController.startRecord();
        },
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: ConfigColor.primaryDefault,
            shape: BoxShape.circle,
          ),
          child: messageRecordingStatus == "recording"? Icon(
            Icons.stop_rounded,
            color: Colors.white,
            size: 56.w
          ) : Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 56.w
          )
        )
      )
    );
  }
}