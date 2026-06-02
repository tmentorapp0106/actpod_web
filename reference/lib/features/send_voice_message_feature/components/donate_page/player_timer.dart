import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../config/color.dart';
import '../../../../utils/time_utils.dart';

class PlayerTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration remainTime = ref.watch(voiceMessageLengthProvider) - ref.watch(messagePlayingTimerProvider)  < Duration.zero? Duration.zero : ref.watch(voiceMessageLengthProvider) - ref.watch(messagePlayingTimerProvider);
    final playingTimer = TimeUtils.formatDuration(remainTime, "mm:ss");
    return Text(
      playingTimer,
      style: TextStyle(
        color: ConfigColor.textColorDefault,
        fontSize: 24.sp
      ),
    );
  }
}