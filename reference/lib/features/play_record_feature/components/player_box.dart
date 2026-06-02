import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/prev_button.dart';
import 'package:quick_share_app/features/play_record_feature/components/play_button.dart';
import 'package:quick_share_app/features/play_record_feature/components/progress_bar.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/comment_controller.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/likes_controller.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/play_record_feature/providers.dart';

import 'fast_forward_button.dart';
import 'likes_button.dart';

class PlayerBox extends ConsumerWidget {
  final PlayerController _playerController;
  final LikesController _likesController;
  final CommentController _commentController;
  final PlayerItemDto storyInfo;
  final List<String> speedOptions = ["0.5X", "0.75X", "1.0X", "1.25X", "1.5X"];

  PlayerBox(this._playerController, this._likesController,
      this._commentController, this.storyInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // semi-transparent
        ),
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            PlayerProgressBar(_playerController, _commentController, storyInfo),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                speedDropDown(ref),
                SizedBox(width: 16.w),
                RewindButton(_playerController),
                SizedBox(width: 28.w),
                PlayButton(_playerController, storyInfo),
                SizedBox(width: 28.w),
                FastforwardButton(_playerController),
                SizedBox(width: 16.w),
                LikesButton(
                  likesController: _likesController,
                  storyInfo: storyInfo,
                ),
              ],
            ),
          ],
        ),
      ),
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
          style: TextStyle(fontSize: 20.w, color: Colors.black),
          items: speedOptions
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                        width: 65.w,
                        height: 24.h,
                        child: AutoSizeText(
                          item,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.w,
                          ),
                        )),
                  ))
              .toList(),
          onChanged: (value) {
            ref.watch(playerSpeedTextProvider.notifier).state = value!;
            if (value == "1.5X") {
              _playerController.setSpeed(1.5);
            } else if (value == "0.5X") {
              _playerController.setSpeed(0.5);
            } else if (value == "1.25X") {
              _playerController.setSpeed(1.25);
            } else if (value == "0.75X") {
              _playerController.setSpeed(0.75);
            } else {
              _playerController.setSpeed(1.0);
            }
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(right: 1),
          ),
          iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
          dropdownStyleData: DropdownStyleData(
            width: 80.w,
            maxHeight: 5 * 36.h,
            isOverButton: true,
            offset: Offset(0, 5 * 36.h + 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 36.h,
            padding: EdgeInsets.zero,
          ),
        ));
  }
}
