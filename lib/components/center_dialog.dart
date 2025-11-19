import 'package:actpod_web/design_system/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CenterDialog extends ConsumerWidget {
  final String title;
  final String content;
  final String leftButtonText;
  final String rightButtonText;
  final Function leftButtonFunction;
  final Function rightButtonFunction;

  CenterDialog({
    super.key,
    required this.title,
    required this.content,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.leftButtonFunction,
    required this.rightButtonFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.w)
        )
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      content: Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 50.h, bottom: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 50.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    leftButtonFunction();
                  },
                  borderRadius: BorderRadius.circular(20.w),
                  child: Container(
                    width: 110.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(
                        width: 1.5,
                        color: DesignColor.primary500
                      )
                    ),
                    child: Center(
                      child: Text(
                        leftButtonText,
                        style: TextStyle(
                          fontSize: 16.w,
                          color: Colors.black
                        ),
                      )
                    )
                  )
                ),
                SizedBox(width: 10.w,),
                InkWell(
                  borderRadius: BorderRadius.circular(20.w),
                  onTap: () {
                    rightButtonFunction();
                  },
                  child: Container(
                    width: 110.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(color: DesignColor.primary500),
                      color: DesignColor.primary500
                    ),
                    child: Center(
                      child: Text(
                        rightButtonText,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.w
                        ),
                      )
                    )
                  )
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}