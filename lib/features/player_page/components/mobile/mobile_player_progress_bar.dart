import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers.dart';

class MobilePlayerProgressBar extends ConsumerWidget {
  final PlayerController _playerController;

  MobilePlayerProgressBar(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioLength = ref.watch(audioLengthProvider);
    final seekPosition = ref.watch(audioPositionProvider);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 332.w,
            height: 16.w,
            child: ProgressBar(
              progress: seekPosition,
              thumbRadius: 6.w,
              barHeight: 4.h,
              thumbColor: DesignColor.primary50,
              baseBarColor: Color(0xFFd6d6d6),
              progressBarColor: DesignColor.primary50,
              total: audioLength,
              onSeek: (duration) {
                _playerController.seekPosition(duration);
              },
              timeLabelLocation: TimeLabelLocation.none,
              timeLabelTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 12.sp
              )
            )
          ),
          SizedBox(
            width: 332.w,
            child: Row(
              children: [
                Text(
                  TimeUtils.formatDuration(seekPosition, "HH:mm:ss"),
                  style: TextStyle(
                    fontSize: 12.w
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatDuration(audioLength, "HH:mm:ss"),
                  style: TextStyle(
                    fontSize: 12.w
                  ),
                )
              ],
            ),
          )
        ]
      )
    );
  }
}