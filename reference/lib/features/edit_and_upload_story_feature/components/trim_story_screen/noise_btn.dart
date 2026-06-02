import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/noise_process_page/noise_model.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/noise_providers.dart';

import '../../../../providers.dart';
import '../../controllers/edit_controller.dart';

class NoiseProcessBtn extends ConsumerWidget {
  final EditController _editController;
  final NoisePreviewPlayerController _noisePreviewPlayerController;
  final EditTrimPlayController _editTrimPlayController;
  final EditTrimPlayerTimerController _editTrimPlayerTimerController;

  NoiseProcessBtn(this._editController, this._noisePreviewPlayerController, this._editTrimPlayController, this._editTrimPlayerTimerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        var tuned = await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.black,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.w)
            )
          ),
          builder: (context) {
            return NoiseModel(_noisePreviewPlayerController, _editTrimPlayerTimerController, _editTrimPlayController.originWavFilePath!);
          }
        );
        // cleanup preview player's provider
        ref.watch(noisePreviewProcessProvider.notifier).state = null;
        ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
        ref.watch(noisePreviewPlayerDurationProvider.notifier).state = Duration.zero;
        ref.watch(noisePreviewPlayerLengthProvider.notifier).state = Duration.zero;
        if(tuned == null) {
          return;
        }
        ref.watch(loadingProvider.notifier).state = true;
        _editController.clearNoise(
          _editTrimPlayController.originWavFilePath!,
          ref.watch(nfProvider) - 80,
          (filePath) {
            _editTrimPlayController.changeAudioPath(filePath);
            ref.watch(loadingProvider.notifier).state = false;
            ref.watch(loadingPercentageProvider.notifier).state = null;
            print("success");
          },
          (progress) {
            ref.watch(loadingPercentageProvider.notifier).state = (progress / _editTrimPlayController.originAudioLength! * 100).toInt();
          },
          () {
            ref.watch(loadingProvider.notifier).state = false;
            ref.watch(loadingPercentageProvider.notifier).state = null;
          }
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
        ),
        child: AutoSizeText(
          "降噪處理",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.w,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}