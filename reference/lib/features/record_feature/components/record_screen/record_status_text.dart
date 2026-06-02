import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../providers/providers.dart';

class RecordStatusText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String text = "";
    switch(ref.watch(recordStatusProvider)) {
      case "recording":
        text = "錄音中...";
        break;
      case "pausing":
        text = "暫停錄音";
        break;
    }

    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.w
      ),
    );
  }
}