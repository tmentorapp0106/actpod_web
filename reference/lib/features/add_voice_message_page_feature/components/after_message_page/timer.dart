import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../providers.dart';

class Timer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String time;
    if(
      ref.watch(afterMessageRecordStatusProvider) == "pending" ||
      ref.watch(afterMessageRecordStatusProvider) == "recording" ||
      ref.watch(afterMessageRecordStatusProvider) == "recorded"
    ) {
      time = TimeUtils.formatDuration(ref.watch(afterMessageRecordTimerProvider), "HH:mm:ss");
    } else {
      time = TimeUtils.formatDuration(ref.watch(afterMessagePlayingTimerProvider), "HH:mm:ss");
    }

    return Text(
      time,
      style: TextStyle(
        fontSize: 18.w
      ),
    );
  }
}