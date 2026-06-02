import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/record_feature/controllers/recorder_controller.dart';

import '../../providers/providers.dart';


class RemoveRecordButton extends ConsumerWidget {
  final RecordController _recordController;

  RemoveRecordButton(this._recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool visible = false;
    final recordStatus = ref.watch(recordStatusProvider);
    visible = recordStatus == "pausing" || recordStatus == "finish";

    return Visibility(
      maintainState: recordStatus == "pending" || recordStatus == "recording",
      maintainAnimation: recordStatus == "pending" || recordStatus == "recording",
      maintainSize: recordStatus == "pending" || recordStatus == "recording",
      visible: visible,
      child: Column(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              _recordController.resetRecording(clear: true);
            },
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle
              ),
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18.w
              ),
            ),
          ),
          SizedBox(height: 3.h,),
          Text(
            "刪除",
            style: TextStyle(
              fontSize: 10.w,
              color: Colors.white
            ),
          )
        ]
      )
    );
  }
}