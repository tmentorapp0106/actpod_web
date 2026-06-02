import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../providers.dart';

class TimerBlocks extends ConsumerWidget {
  final ScrollController _scrollController;

  TimerBlocks(this._scrollController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration remainDuration = ref.watch(blockInfosProvider).isEmpty? Duration.zero : ref.watch(blockInfosProvider).last.to;
    List<Widget> timerBlocks = [Container(width: ScreenUtil().screenWidth / 2,color: Colors.black,)];

    Duration blockDuration = const Duration(seconds: 10);
    while(remainDuration > const Duration(seconds: 10)) {
      timerBlocks.add(tenSecBlock(blockDuration, ref));
      remainDuration -= const Duration(seconds: 10);
      blockDuration += const Duration(seconds: 10);
    }
    timerBlocks.add(lastBlock(remainDuration, ref));
    timerBlocks.add(Container(width: ScreenUtil().screenWidth / 2,color: Colors.black,));

    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: timerBlocks.length,
        itemBuilder: (context, index) {
          return timerBlocks[index];
        },
      )
    );
  }

  Widget tenSecBlock(Duration duration, WidgetRef ref) {
    return SizedBox(
      width: const Duration(seconds: 10).inMilliseconds / ref.watch(barScaleProvider),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.circle, color: Colors.grey, size: 5.w,),
          SizedBox(
            height: 20.h,
            child: AutoSizeText(
              TimeUtils.formatDuration(duration, "HH:ss:mm"),
              style: TextStyle(
                color: Colors.white
              ),
            )
          ),
          SizedBox(width: 5.w,)
        ]
      ),
    );
  }

  Widget lastBlock(Duration duration, WidgetRef ref) {
    return SizedBox(
      width: duration.inMilliseconds / ref.watch(barScaleProvider),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: Colors.grey, size: 5.w,),
        ]
      ),
    );
  }
}