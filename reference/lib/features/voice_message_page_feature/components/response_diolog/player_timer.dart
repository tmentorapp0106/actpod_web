import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../utils/time_utils.dart';
import '../../providers.dart';


class PlayerTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration remainTime = ref.watch(responseLengthProvider);
    remainTime = ref.watch(responseLengthProvider) - ref.watch(responsePlayingTimerProvider);
    if(remainTime < Duration.zero) {
      remainTime = Duration.zero;
    }
    final playingTimer = TimeUtils.formatDuration(remainTime, "mm:ss");
    return Text(
      playingTimer,
      style: TextStyle(
        color: ConfigColor.textColorDefault,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp
      ),
    );
  }
}