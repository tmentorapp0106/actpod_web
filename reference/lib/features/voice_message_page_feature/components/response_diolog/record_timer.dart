import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../providers.dart';


class RecordTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordTimer = TimeUtils.formatDuration(ref.watch(responseRecordTimerProvider), "mm:ss");
    return Text(
      "$recordTimer/05:00",
      style: TextStyle(
        color: ConfigColor.textColorDefault,
        fontSize: 24.sp
      ),
    );
  }
}