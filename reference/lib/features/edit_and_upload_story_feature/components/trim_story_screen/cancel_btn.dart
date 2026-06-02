import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers.dart';

class CancelBtn extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.watch(cutFromProvider.notifier).state = null;
        ref.watch(cutToProvider.notifier).state = null;
      },
      child: SizedBox(
          width: 75.w,
          child: AutoSizeText(
            "取消剪輯",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ref.watch(cutFromProvider) == null? Colors.grey : Colors.white,
                fontSize: 16.w
            ),
          )
      ),
    );
  }
}