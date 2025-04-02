import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileListenCount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return storyInfo == null? const SizedBox.shrink() : Text(
      "收聽次數：${storyInfo.count}",
      style: TextStyle(
        fontSize: 12.w
      ),
    );
  }
}