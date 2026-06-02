import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../utils/time_utils.dart';
import '../../providers.dart';


class AudioLength extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = TimeUtils.formatDuration(ref.watch(responseLengthProvider), "mm:ss");
    return Text(
      length,
      style: TextStyle(
        color: ConfigColor.textColorDefault,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp
      ),
    );
  }
}