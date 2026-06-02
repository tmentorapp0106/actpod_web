import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../config/color.dart';
import '../../../../utils/time_utils.dart';

class AudioLength extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = TimeUtils.formatDuration(ref.watch(voiceMessageLengthProvider), "mm:ss");
    return Text(
      length,
      style: TextStyle(
        color: ConfigColor.textColorDefault,
        fontSize: 48.sp
      ),
    );
  }
}