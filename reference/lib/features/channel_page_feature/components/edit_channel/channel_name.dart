import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

import '../../../../config/color.dart';

class ChannelName extends ConsumerWidget {
  final TextEditingController nameController;

  ChannelName(this.nameController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.w),
          border: Border.all()
      ),
      width: 350.w,
      child: TextField(
        controller: nameController,
        maxLines: 1,
        style: TextStyle(
          color: ConfigColor.textColorDefault,
          fontSize: 16.w
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          hintText: "頻道名稱",
          hintStyle: TextStyle(
            color: Colors.grey
          )
        ),
      )
    );
  }
}