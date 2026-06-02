import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:record/record.dart';

import '../../../../config/color.dart';
import '../../../../providers.dart';
import '../../../../utils/audio_utils.dart';
import '../../../edit_and_upload_story_feature/edit_and_upload_story_screen.dart';
import '../../controllers/recorder_controller.dart';
import 'finish_record_dialog.dart';

class CheckButtonWidget extends ConsumerWidget {
  final RecordController recordController;
  final AudioRecorder recorderController;

  CheckButtonWidget(
    this.recordController,
    this.recorderController,
    {super.key}
  );

  void processNormalization(WidgetRef ref, BuildContext context) {
    int wavProgress = 0;
    int m4aProgress = 0;
    String? wavFilePath;
    String? m4aFilePath;

    void onProgressChange() {
      ref.watch(loadingPercentageProvider.notifier).state = ((wavProgress + m4aProgress) / 2).toInt();
    }

    Future<void> onProcessComplete() async {
      if(wavFilePath != null && m4aFilePath != null && context.mounted) {
        await recordController.resetRecording(clear: false);
        ref.watch(loadingTextProvider.notifier).state = null;
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
        if(!context.mounted) {
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return RecordPreviewScreen(
            false, 
            originWavFilePath: recordController.audioFilePath, 
            normalizedM4aFilePath: m4aFilePath!, 
            normalizedWavFilePath: wavFilePath!, 
            waveformData: recordController.waveformData
          );
        }));
      }
    }

    AudioUtils.normalizeAudio(
      recordController.audioFilePath,
      "wav",
      (filePath) async {
        wavFilePath = filePath;
        onProcessComplete();
      },
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        ref.watch(loadingTextProvider.notifier).state = null;
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
      },
      (progress) {
        wavProgress = (progress / recordController.currentRecordTime.inMilliseconds * 100).toInt();
        onProgressChange();
      },
      false,
    );
    AudioUtils.normalizeAudio(
      recordController.audioFilePath,
      "m4a",
      (filePath) async {
        m4aFilePath = filePath;
        onProcessComplete();
      },
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
      },
      (progress) {
        m4aProgress = (progress / recordController.currentRecordTime.inMilliseconds * 100).toInt();
        onProgressChange();
      },
      false
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordStatus = ref.watch(recordStatusProvider);

    return recordStatus == "pausing" || recordStatus == "finish"?
    Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            if(ref.watch(recordTimerProvider).inSeconds < 1) { // prevent divide by 0 while extracting waveform
              return;
            }
            recordController.pauseRecord()
            .then((value) async {
              if(recordController.checkDurationConstraint()) {
                if(!context.mounted) {
                  return;
                }
                var navigate = await showDialog(
                  context: context,
                  builder: (context) {
                    return FinishRecordDialog(
                        recordController,
                        recorderController
                    );
                  }
                );
                if(navigate != null) {
                  if(!context.mounted) {
                    return;
                  }
                  ref.watch(loadingTextProvider.notifier).state = "自動調整音量中，請耐心等候...";
                  processNormalization(ref, context);
                }
              } else {
                ToastService.showNoticeToast("錄音長度需要超過2分鐘");
              }
            });
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              shape: BoxShape.circle
            ),
            padding: EdgeInsets.all(5.w),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 15.w
            )
          ),
        ),
        SizedBox(height: 3.h,),
        Text(
          "完成",
          style: TextStyle(
            fontSize: 10.w,
            color: Colors.white
          ),
        )
      ]
    ) : SizedBox(width: 30.w,);
  }
}