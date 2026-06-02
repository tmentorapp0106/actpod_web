
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';

import '../../../../components/waveform_painter.dart';
import '../../providers/providers.dart';

class RecordWave extends ConsumerWidget {
  final AudioRecorder recorderController;


  RecordWave(this.recorderController, {super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(recordStatusProvider) != "pending",
      child: SizedBox(
        width: ScreenUtil().screenWidth,
        height: 340.h,
        child: CustomPaint(
          painter: WaveformPainter(
            data: ref.watch(waveformDataProvider),
            totalWidth: ScreenUtil().screenWidth,
            stretch: 1,
            color: Colors.white,
            barWidth: 2,
            height: 340.h
          )
        )
      )
    );
  }
}