import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/play_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/record_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';
import 'package:quick_share_app/utils/color_utils.dart';
import 'package:quick_share_app/utils/device_utils.dart';
import 'package:vibration/vibration.dart';

import '../../../../config/color.dart';

class SendMessageMiddleArea extends ConsumerWidget {
  final RecordController recordController;
  final RecorderController recorderController;
  final PlayerController playerController;

  SendMessageMiddleArea(this.recordController, this.recorderController, this.playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(sendVoiceMessageStatusProvider);

    Widget statusWidget;
    if (messageRecordingStatus == "recording" || messageRecordingStatus == "pending") {
      statusWidget = AudioWaveforms(
        size: Size(300.w, 200.h),
        shouldCalculateScrolledPosition: true,
        recorderController: recorderController,
        enableGesture: false,
        waveStyle: WaveStyle(
          scaleFactor: 150.h,
          waveColor: Colors.black,
          showDurationLabel: false,
          waveThickness: 2.w,
          spacing: 10.0001.w,
          showBottom: true,
          extendWaveform: true,
          showMiddleLine: false,
        ),
      );
    } else {
      statusWidget = AudioFileWaveforms(
        size: Size(300.w, 200.h),
        playerController: playerController,
        waveformType: WaveformType.long,
        waveformData: const [],
        enableSeekGesture: false,
        playerWaveStyle: PlayerWaveStyle(
          showSeekLine: false,
          fixedWaveColor: Colors.black,
          liveWaveColor: ConfigColor.blackSecondary,
          scrollScale: 0,
          scaleFactor: 300.h,
          waveThickness: 2.w,
          spacing: 10.0001.w,
          showBottom: true,
        ),
      );
    }

    return SizedBox(
      width: DeviceUtils.isTablet(MediaQuery.of(context))? 150.w : 300.w,
      height: DeviceUtils.isTablet(MediaQuery.of(context))? 150.w : 200.w,
      child: statusWidget
    );
  }

}