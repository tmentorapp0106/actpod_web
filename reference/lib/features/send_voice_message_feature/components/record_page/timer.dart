import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/audio_length.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/play_page/player_timer.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/record_timer.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

class Timer extends ConsumerWidget {
  const Timer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(sendVoiceMessageStatusProvider);

    if(status == "pending") {
      return SizedBox(height: 48.w,);
    } else {
      return RecordTimer();
    }
  }
}