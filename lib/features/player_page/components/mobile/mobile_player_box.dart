import 'package:actpod_web/features/player_page/components/mobile/mobile_play_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/player_controller.dart';
import '../../providers.dart';

class MobilePlayerBox extends ConsumerWidget {
  final PlayerController _playerController;
  final List<String> speedOptions = [
    "1.0X",
    "0.5X",
    "1.5X"
  ];

  MobilePlayerBox(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.only(top: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: Colors.grey
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            MobilePlayerProgressBar(_playerController),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    speedDropDown(ref),
                  ],
                ),
                MobilePlayButton(_playerController), // stays centered in the stack
              ],
            ),
          ],
        )
      )
    );
  }

  Widget speedDropDown(WidgetRef ref) {
    return SizedBox(
      width: 65.w,
      child: DropdownButtonFormField2<String>(
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
        value: ref.watch(playerSpeedTextProvider),
        style: TextStyle(
          color: Colors.black
        ),
        items: speedOptions.map((item) => DropdownMenuItem<String>(
          value: item,
          child: SizedBox(
            width: 65.w,
            height: 15.h,
            child: AutoSizeText(
              item,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.w,
              ),
            )
          ),
        )).toList(),
        onChanged: (value) {
          ref.watch(playerSpeedTextProvider.notifier).state = value!;
          if(value == "1.5X") {
            _playerController.setSpeed(1.5);
          } else if(value == "0.5X") {
            _playerController.setSpeed(0.5);
          } else {
            _playerController.setSpeed(1.0);
          }
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(right: 1),
        ),
        iconStyleData: const IconStyleData(
          icon: SizedBox.shrink()
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      )
    );
  }
}