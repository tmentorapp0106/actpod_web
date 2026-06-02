import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/components/center_dialog.dart';
import 'package:quick_share_app/features/record_feature/controllers/recorder_controller.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_fix_utils.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:record/record.dart';

class FinishRecordDialog extends ConsumerWidget {
  final RecordController recordController;
  final AudioRecorder recorderController;

  FinishRecordDialog(
    this.recordController,
    this.recorderController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return CenterDialog(
      title:  AppLocalizations.of(context)!.doneRecording,
      // content: AppLocalizations.of(context)!.doneRecordingDescription,
      content: "是否確定完成錄音？\n結束後將無法繼續錄音",
      leftButtonText: "取消",
      rightButtonText: "確定",
      leftButtonFunction: () {
        Navigator.of(context).pop();
      },
      rightButtonFunction: () async {
        ref.watch(loadingProvider.notifier).state = true;
        await recordController.stopRecord();
        if(Platform.isAndroid) {
          try {
            await AudioFixUtil.resetToMediaVolume();
          } catch(e) {
            print(e);
          }
        }
        Navigator.of(context).pop(true);
      },
    );
  }
}