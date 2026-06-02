import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../controllers/recorder_controller.dart';

class SoundEffectDialog extends ConsumerWidget {
  RecordController recordController;

  SoundEffectDialog(this.recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ConfigColor.backgroundThird,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10.w)
          )
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 5.h),
      content: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              title(),
              soundEffect(ref, "Applause")
            ],
          ),
          Positioned(
            top: 1.h,
            right: 10.w,
            child: close(context)
          )
        ]
      )
    );
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sound Effects",
          style: TextStyle(
            color: ConfigColor.textColorDefault,
            fontSize: 24.sp
          ),
        )
      ]
    );
  }

  Widget soundEffect(WidgetRef ref, String effectName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: ConfigColor.backgroundFourth
      ),
      child: Row(
        children: [
          SizedBox(width: 10.w,),
          Text(
            effectName,
            style: TextStyle(
              fontSize: 16.sp,
              color: ConfigColor.textColorDefault
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ConfigColor.primaryDefault
            ),
            child: InkWell(
              onTap: () {
              },
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 20.w
              )
            )
          )
        ],
      ),
    );
  }

  Widget close(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Icon(
        Icons.close,
        size: 20.w,
        color: Colors.white,
      )
    );
  }
}