import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileContentSwitch extends ConsumerWidget {
  final PlayerController playerController;

  MobileContentSwitch({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playContent = ref.watch(playContentProvider);

    if(playContent == PlayContent.story) {
      return Visibility(
        visible: ref.watch(interactiveMessageInfoListProvider) != null && ref.watch(interactiveMessageInfoListProvider)!.isNotEmpty,
        child: Positioned(
          bottom: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: () async {
              playerController.playIndex(1);
            },
            child: Container(
              padding: EdgeInsets.only(left: 8.w, right: 4.w, top: 4.h, bottom: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xff222222).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "語音留言",
                    style: TextStyle(color: Colors.white, fontSize: 12.w),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12.w,
                  )
                ],
              ),
            ),
          )
        )
      );
    } else {
      return Visibility(
        visible: ref.watch(interactiveMessageInfoListProvider) != null && ref.watch(interactiveMessageInfoListProvider)!.isNotEmpty,
        child: Positioned(
          bottom: 8.h,
          left: 8.w,
          child: GestureDetector(
            onTap: () async {
              playerController.playIndex(0);
            },
            child: Container(
              padding: EdgeInsets.only(left: 4.w, right: 8.w, top: 4.h, bottom: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xff222222).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 12.w,
                  ),
                  Text(
                    "收聽正片",
                    style: TextStyle(color: Colors.white, fontSize: 12.w),
                  ),
                ],
              )
            ),
          ),
        )
      );
    }
  }
}