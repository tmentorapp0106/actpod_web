import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/color.dart';

class CenterDialogWithOneButton extends ConsumerWidget {
  final String title;
  final String content;
  final String buttonText;
  final Function buttonFunction;

  CenterDialogWithOneButton({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    required this.buttonFunction
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ConfigColor.greySecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.w)
        )
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 400.h
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                    ),
                  ),
                ]
              )
            )
          ),
          SizedBox(height: 10.h,),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.w)),
                  onTap: () {
                    buttonFunction();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 1.w, color: Colors.grey))
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: ConfigColor.redDefault,
                            fontSize: 20.sp
                          ),
                        )
                      )
                  )
                )
              )
            ],
          )
        ],
      ),
    );
  }
}