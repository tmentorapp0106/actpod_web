import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

class ChangeVoiceCheckBox extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if(ref.watch(sendVoiceMessageStatusProvider) == "pending") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: ref.watch(changeVoiceProvider),
            activeColor: DesignColor.primary50,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool? newValue) {
              ref.watch(changeVoiceProvider.notifier).state = newValue?? false;
            },
          ),
          const Text("變換聲音"),
          SizedBox(width: 8.w,)
        ]
      );
    }

    return SizedBox(height: 44.h,);
  }
}