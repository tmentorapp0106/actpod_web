import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';

import '../../../../config/color.dart';
import '../../providers/noise_providers.dart';

class NoiseProgressBar extends ConsumerWidget {
  final NoisePreviewPlayerController _noisePlayerController;

  NoiseProgressBar(this._noisePlayerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 320.w,
      height: 8.w,
      child: ProgressBar(
        progress: ref.watch(noisePreviewPlayerDurationProvider),
        thumbRadius: 5.w,
        barHeight: 6.h,
        thumbColor: ConfigColor.primaryDefault,
        baseBarColor: ConfigColor.greyDefault,
        progressBarColor: ConfigColor.primaryDefault,
        total: ref.watch(noisePreviewPlayerLengthProvider),
        onSeek: (duration) {
          _noisePlayerController.seek(duration);
        },
        timeLabelLocation: TimeLabelLocation.none,
        timeLabelTextStyle: TextStyle(
          color: ConfigColor.textColorDefault,
          fontSize: 12.sp
        )
      )
    );
  }
}