import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../design_system/color.dart';

class DescriptionTextField extends ConsumerWidget {
  final TextEditingController controller;

  DescriptionTextField(this.controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: DesignColor.neutral300
          )
        ),
      width: 350.w,
      child: TextField(
        maxLines: 8,
        controller: controller,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
            color: ConfigColor.textColorDefault,
            fontSize: 16.w
        ),
        decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            hintText: "輸入敘述 (800字以內)",
            hintStyle: TextStyle(
              color: Colors.grey
            )
        ),
      )
    );
  }
}