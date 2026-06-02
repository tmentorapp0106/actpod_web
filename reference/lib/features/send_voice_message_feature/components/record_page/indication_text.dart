import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../config/color.dart';

class IndicationText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(sendVoiceMessageStatusProvider) == "pending"? "按住開始錄製(5分鐘內)" : "釋放結束錄音",
      style: TextStyle(
        color: Color(0xFF8f8f8f),
        fontSize: 16.w
      ),
    );
  }
}