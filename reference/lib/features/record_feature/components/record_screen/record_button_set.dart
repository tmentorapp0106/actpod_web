import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/record_button.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/record_check_button.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/record_remove_button.dart';
import 'package:quick_share_app/features/record_feature/controllers/recorder_controller.dart';
import 'package:record/record.dart';

import '../../providers/providers.dart';

class RecordButtonSet extends ConsumerWidget {
  final RecordController recordController;
  final AudioRecorder recorderController;

  RecordButtonSet(
    this.recordController,
    this.recorderController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        RemoveRecordButton(recordController),
        const Spacer(),
        RecordButtonWidget(recordController),
        const Spacer(),
        CheckButtonWidget(recordController, recorderController),
        const Spacer(),
      ],
    );
  }
}