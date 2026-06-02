
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../../../utils/time_utils.dart';
import '../../providers/providers.dart';

class RecordTimerWidget extends ConsumerWidget {
  const RecordTimerWidget({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordTimer = ref.watch(recordTimerProvider);

    return Visibility(
      visible: ref.watch(recordStatusProvider) != "pending",
      child: Padding(
        padding: EdgeInsets.only(bottom: 25.h),
        child: AutoSizeText(
          TimeUtils.formatDuration(recordTimer, "mm:ss"),
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp
          ),
        )
      )
    );
  }
}