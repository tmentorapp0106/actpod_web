import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../design_system/color.dart';

class HintText extends ConsumerWidget {
  final bool isStoryOwner;

  HintText(this.isStoryOwner);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if(isStoryOwner) {
      return Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 16.h, bottom: 8.h),
          child: Text(
            "注意：送出後，這段語音會加進故事播畢後的互動環節。",
          )
      );
    }

    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: ref.watch(acceptAddProvider),
            activeColor: DesignColor.primary50,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool? newValue) {
              ref.watch(acceptAddProvider.notifier).state = newValue?? false;
            },
          ),
          const Text("允許 Podcaster 添加至互動內容"),
          SizedBox(width: 8.w,)
        ]
    );
  }
}