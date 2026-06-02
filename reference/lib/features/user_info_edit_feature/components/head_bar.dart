import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/user_info_edit_feature/controllers/edit_user_info_controller.dart';
import 'package:quick_share_app/features/user_info_edit_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

import '../../../config/color.dart';

class HeadBar extends ConsumerWidget {
  final EditUserInfoController _editUserInfoController;

  HeadBar(this._editUserInfoController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Align(
          alignment: Alignment(-1.0, 0.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ConfigColor.textColorDefault,
              size: 24.sp,
            ),  
          )
        ),
        Align(
          alignment: Alignment(0.0, 0.0),
          child: Text(
            "編輯資訊",
            style: TextStyle(
              color: ConfigColor.textColorDefault,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold
            ),
          )
        ),
        // Align(
        //   alignment: Alignment(1.0, 0.0),
        //   child: InkWell(
        //     onTap: () {
        //       ref.watch(loadingProvider.notifier).state = true;
        //       _editUserInfoController.updateUserInfo().then((updated) {
        //         ref.watch(loadingProvider.notifier).state = false;
        //         if(updated) {
        //           Navigator.of(context).pop();
        //         }
        //       });
        //     },
        //     child: Text(
        //       "完成",
        //       style: TextStyle(
        //         color: ConfigColor.textColorDefault,
        //         fontSize: 18.sp,
        //       ),
        //     )
        //   )
        // )
      ],
    );
  }
}