import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/providers.dart';

class ContinueRecordText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(recordStatusProvider) == "pausing",
      child: SizedBox(
        height: 30.h,
        child: AutoSizeText(
          "繼續錄音",
          style: TextStyle(
            fontSize: 16.w,
            color: Colors.white
          ),
        ),
      )
    );
  }
}