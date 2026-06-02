import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'record_timer.dart';
import 'player_timer.dart';
import 'audio_length.dart';

import '../../providers.dart';

class RecorderPlayerTimer extends ConsumerWidget {
  const RecorderPlayerTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(responseStatusProvider);

    if(status == "pending") {
      return SizedBox(height: 48.h,);
    } else if(status == "recording") {
      return RecordTimer();
    } else if (status == "playing" || status == "pausing") {
      return PlayerTimer();
    } else {
      return AudioLength();
    }
  }
}