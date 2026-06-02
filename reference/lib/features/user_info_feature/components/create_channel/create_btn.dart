import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../controllers/create_channel_controller.dart';

class CreateChannelBtn extends ConsumerWidget {
  final CreateChannelController _createChannelController;

  CreateChannelBtn(this._createChannelController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if(await _createChannelController.createChannel()) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(30.w),
      child: Container(
        width: 96.w,
        height: 40.h,
        decoration: BoxDecoration(
            color: DesignColor.primary50,
            borderRadius: BorderRadius.circular(30.w)
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Center(
          child: AutoSizeText(
            "創建頻道",
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.white
            )
          ),
        ),
      )
    );
  }
}