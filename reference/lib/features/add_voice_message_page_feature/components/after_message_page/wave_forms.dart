import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/after_message_recorder_controller.dart';

import '../../../../config/color.dart';
import '../../providers.dart';

class WaveForms extends ConsumerWidget {
  final AfterMessageRecorderController _afterMessageRecorderController;

  WaveForms(this._afterMessageRecorderController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(afterMessageRecordStatusProvider);

    Widget statusWidget;
    if (messageRecordingStatus == "recording" || messageRecordingStatus == "pending") {
      statusWidget = AudioWaveforms(
        size: Size(300.w, 150.h),
        shouldCalculateScrolledPosition: true,
        recorderController: _afterMessageRecorderController.recordService.recorderController,
        enableGesture: false,
        waveStyle: WaveStyle(
          scaleFactor: 100.h,
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
        size: Size(300.w, 150.h),
        playerController: _afterMessageRecorderController.recordService.playerController,
        waveformType: WaveformType.long,
        waveformData: const [],
        enableSeekGesture: false,
        playerWaveStyle: PlayerWaveStyle(
          showSeekLine: false,
          fixedWaveColor: Colors.black,
          liveWaveColor: ConfigColor.blackSecondary,
          scrollScale: 0,
          scaleFactor: 200.h,
          waveThickness: 2.w,
          spacing: 10.0001.w,
          showBottom: true,
        ),
      );
    }

    return SizedBox(
        width: 300.w,
        height: 150.w,
        child: statusWidget
    );
  }
}