import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../providers.dart';

class UpperArea extends ConsumerWidget {
  final bool isStoryOwner;

  UpperArea(this.isStoryOwner);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isStoryOwner? "添加語音留言" : "傳送新的語音留言串",
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold,
              color: ConfigColor.textColorDefault
            ),
          ),
          SizedBox(height: 12.h,),
          hintText()
        ]
      )
    );
  }

  Widget hintText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            isStoryOwner? "添加的語音留言會於正片播畢後，開啟語音互動環節。" : "你的留言只有該故事的創作者會收到，並有機會被添加至故事中公開。",
            style: TextStyle(
              fontSize: 14.w,
              color: Colors.grey
            ),
          )
        )
      ]
    );
  }
}