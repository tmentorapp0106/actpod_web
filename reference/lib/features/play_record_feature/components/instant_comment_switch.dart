import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/color.dart';
import '../providers.dart';

class InstantCommentSwitch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        bool oldState = ref.watch(instantCommentVisibilityProvider);
        if(oldState) {
          List<Widget> commentWidgets = ref.watch(instantCommentWidgets);
          for(int i = 0; i < commentWidgets.length; i++) {
            commentWidgets[i] = const SizedBox.shrink();
          }
          ref.watch(instantCommentWidgets.notifier).state = [...commentWidgets];
          instantCommentWaitingQueue.clear();
          instantCommentPositionQueue.clear();
          ref.watch(instantCommentVisibilityProvider.notifier).state = false;
        } else {
          ref.watch(instantCommentVisibilityProvider.notifier).state = true;
        }
      },
      child: Container(
        width: 56.w,
        height: 32.h,
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ref.watch(instantCommentVisibilityProvider)? DesignColor.neutral50 : DesignColor.actpodPrimary50
        ),
        child: Center(
            child: AutoSizeText(
              ref.watch(instantCommentVisibilityProvider)? "即時留言\nOFF" : "即時留言\nON",
              style: TextStyle(
                color: ref.watch(instantCommentVisibilityProvider)? Colors.black : DesignColor.actpodPrimary500
              ),
              minFontSize: 0,
              textAlign: TextAlign.center,
            )
        ),
      )
    );
  }
}