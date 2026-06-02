import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../../../utils/time_utils.dart';
import '../../providers.dart';

class PlayerTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration totalLength = ref.watch(totalLengthProvider);
    String text = "";
    if(ref.watch(isScrollingProvider) || ref.watch(isSeekingProvider)) {
      text = "seeking..." + "/" + TimeUtils.formatDuration(totalLength, "HH:mm:ss");
    } else {
      text = TimeUtils.formatDuration(ref.watch(playTimerProvider), "HH:mm:ss") + "/" + TimeUtils.formatDuration(totalLength, "HH:mm:ss");
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.w,
        color: Colors.white
      ),
    );
  }
}