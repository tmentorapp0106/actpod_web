import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers.dart';

class PlayerProgressBar extends ConsumerWidget {
  final PlayerController _playerController;

  PlayerProgressBar(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioLength = ref.watch(audioLengthProvider);
    final seekPosition = ref.watch(audioPositionProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            InkWell(
              onTap: () {
                _playerController.backward(const Duration(seconds: 15));
              },
              child: Image.asset(
                "assets/icons/backward_15.png",
                width: 32.w,
                height: 32.w,
              )
            ),
            SizedBox(height: 2.h,),
            Text(
              TimeUtils.formatDuration(seekPosition, "HH:mm:ss"),
              style: TextStyle(
                fontSize: 12.w
              ),
            )
          ],
        ),
        SizedBox(width: 5.w,),
        SizedBox(
          width: 250.w,
          height: 8.w,
          child: ProgressBar(
            progress: seekPosition,
            thumbRadius: 5.w,
            barHeight: 6.h,
            thumbColor: Colors.black,
            baseBarColor: Colors.grey,
            progressBarColor: Colors.black,
            total: audioLength,
            onSeek: (duration) {
              _playerController.seekPosition(duration);
            },
            timeLabelLocation: TimeLabelLocation.none,
            // timeLabelPadding: 4.h,
            timeLabelTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 12.sp
            )
          )
        ),
        SizedBox(width: 5.w,),
        Column(
          children: [
            InkWell(
              onTap: () {
                _playerController.forward(const Duration(seconds: 15));
              },
              child: Image.asset(
                "assets/icons/forward_15.png",
                width: 32.w,
                height: 32.w,
              )
            ),
            SizedBox(height: 2.h,),
            Text(
              TimeUtils.formatDuration(audioLength, "HH:mm:ss"),
              style: TextStyle(
                fontSize: 12.w
              ),
            )
          ],
        ),
      ]
    );
  }
}