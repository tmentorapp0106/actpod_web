import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/features/record_feature/components/sound_effect_dialog.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../config/color.dart';
import '../../controllers/recorder_controller.dart';
import '../../providers/providers.dart';

class SoundEffectButton extends ConsumerWidget {
  RecordController recordController;
  
  SoundEffectButton(this.recordController);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool visible = false;
    final recordStatus = ref.watch(recordStatusProvider);
    visible = recordStatus == "recording";

    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                border: Border.all(
                  color: Colors.white
                )
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/icons/sound_effect.png",
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(width: 5.w,),
                  Text(
                    AppLocalizations.of(context)!.soundEffect,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ConfigColor.textColorDefault
                    ),
                  )
                ]
              )
            ),
          )
        ]
      )
    );
  }
}