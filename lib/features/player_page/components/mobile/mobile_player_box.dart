import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_play_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_player_progress_bar.dart';
import 'package:actpod_web/features/player_page/service/redirect.dart';
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
      child: Column(
        children: [
          MobilePlayerProgressBar(_playerController),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              speedDropDown(ref),
              backward(),
              MobilePlayButton(_playerController),
              forward(),
              like(ref)
            ],
          )
        ],
      )
    );
  }

  Widget like(WidgetRef ref) {
    return SizedBox(
      width: 65.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              RedirectService.toDownload();
            },
            child: Icon(
              Icons.favorite,
              color: DesignColor.primary50,
              size: 24.w,
            ),
          ),
          SizedBox(width: 2.w,),
          Text(
            ref.watch(storyStateProvider) == null? "" : ref.watch(storyStateProvider)!.likeCount.toString(),
            style: TextStyle(
              color: DesignColor.neutral70,
              fontSize: 14.w
            ),
          )
        ]
      )
    );
  }

  Widget backward() {
    return InkWell(
      onTap: () {
        _playerController.backward(const Duration(seconds: 15));
      },
      child: Image.asset(
        "assets/icons/backward_15.png",
        width: 32.w,
        height: 32.w,
      )
    );
  }

  Widget forward() {
    return InkWell(
      onTap: () {
        _playerController.forward(const Duration(seconds: 15));
      },
      child: Image.asset(
        "assets/icons/forward_15.png",
        width: 32.w,
        height: 32.w,
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