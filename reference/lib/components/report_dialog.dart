import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/color.dart';

class ReportDialog extends ConsumerWidget {
  final String title;
  final Function sendFunction;
  final TextEditingController textController;

  ReportDialog({
    super.key,
    required this.title,
    required this.sendFunction,
    required this.textController
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
                TextField(
                  maxLines: 6,
                  maxLength: 200,
                  controller: textController,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'report description',
                    hintStyle: const TextStyle(
                      color: Colors.grey
                    )
                  ),
                )
              ]
            )
          ),
          SizedBox(height: 10.h,),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.w)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(width: 0.5.w, color: Colors.grey),top: BorderSide(width: 1.w, color: Colors.grey),)
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20.sp
                        ),
                      )
                    )
                  )
                )
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20.w)),
                  onTap: () {
                    sendFunction();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(width: 0.5.w, color: Colors.grey),top: BorderSide(width: 1.w, color: Colors.grey))
                    ),
                    child: Center(
                      child: Text(
                        "Send",
                        style: TextStyle(
                          color: ConfigColor.redDefault,
                          fontSize: 20.sp
                        ),
                      )
                    )
                  )
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}