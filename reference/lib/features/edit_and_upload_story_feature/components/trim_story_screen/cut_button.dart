import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/apiManagers/exception_system_api_manager.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/const/const.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../../dto/block_info_dto.dart';
import '../../../../providers.dart';
import '../../controllers/edit_trim_player_timer_controller.dart';

class CutAndVolumeButton extends ConsumerWidget {
  final EditTrimPlayerTimerController _playerTimerController;
  final EditTrimPlayController _playController;

  CutAndVolumeButton(this._playerTimerController, this._playController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent, // Ensures no extra background
          child: InkWell(
            onTap: () async {
              if( ref.watch(isSeekingProvider) || ref.watch(isScrollingProvider)) {
                ToastService.showNoticeToast("定位中");
                return;
              }
              Duration currentPosition = _playerTimerController.getCursor();
              List<BlockInfoDto> blockInfoList = ref.watch(blockInfosProvider);

              // 如果太靠近邊界則認定是要選取邊界
              int blockIndex = 0;
              for(int i = 0; i < blockInfoList.length; i++) {
                if(blockInfoList[i].from <= currentPosition && blockInfoList[i].to > currentPosition) {
                  blockIndex = i;
                }
              }
              if(currentPosition - blockInfoList[blockIndex].from < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].from.inMilliseconds, stopTrackFirst: true);
                ref.watch(cutToProvider.notifier).state = _playerTimerController.getCursor();
                ref.watch(cutFromProvider.notifier).state = _playerTimerController.getCursor();
              } else if(blockInfoList[blockIndex].to - currentPosition < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].to.inMilliseconds, stopTrackFirst: true);
                ref.watch(cutFromProvider.notifier).state = _playerTimerController.getCursor();
                ref.watch(cutToProvider.notifier).state = _playerTimerController.getCursor();
              } else {
                ref.watch(cutFromProvider.notifier).state = currentPosition;
                ref.watch(cutToProvider.notifier).state = currentPosition;
              }
            },
            borderRadius: BorderRadius.circular(50), // Keeps ripple inside the circle
            splashColor: Colors.white.withOpacity(0.3), // Ripple effect color
            child: ClipOval( // Ensures a perfect circular shape
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/trim_page/trim_start.svg",
                      width: 32.w,
                      height: 32.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      width: 55.w,
                      height: 20.h,
                      child: AutoSizeText(
                        "剪輯開始",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 50.w,),
        Material(
          color: Colors.transparent, // Ensures no extra background
          child: InkWell(
            onTap: () async {
              if( ref.watch(isSeekingProvider) || ref.watch(isScrollingProvider)) {
                ToastService.showNoticeToast("定位中");
                return;
              }
              if (ref.watch(cutFromProvider) == null) {
                return;
              }

              // 如果太靠近邊界則認定是要選取邊界
              Duration currentPosition = _playerTimerController.getCursor();
              int blockIndex = 0;
              List<BlockInfoDto> blockInfoList = ref.watch(blockInfosProvider);

              // 如果太靠近邊界則認定是要選取邊界
              for(int i = 0; i < blockInfoList.length; i++) {
                if(blockInfoList[i].from <= currentPosition && blockInfoList[i].to > currentPosition) {
                  blockIndex = i;
                }
              }
              if(currentPosition - blockInfoList[blockIndex].from < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].from.inMilliseconds, stopTrackFirst: true);
                ref.watch(cutToProvider.notifier).state = _playerTimerController.getCursor();
              } else if(blockInfoList[blockIndex].to - currentPosition < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].to.inMilliseconds, stopTrackFirst: true);
                ref.watch(cutToProvider.notifier).state = _playerTimerController.getCursor();
              } else {
                ref.watch(cutToProvider.notifier).state = currentPosition;
              }

              if (ref.watch(cutFromProvider) != null && ref.watch(cutFromProvider)! < ref.watch(cutToProvider)!) {
                await _playController.pauseAudio();
                List<BlockInfoDto> rollbackBlocks = ref.watch(blockInfosProvider);
                Duration totalLength = ref.watch(totalLengthProvider);
                Duration cutFrom = ref.watch(cutFromProvider)!;
                try {
                  await _playController.cutStory(ref.watch(cutFromProvider)!, ref.watch(cutToProvider)!);
                } catch(e) {
                  final deviceType = Platform.isAndroid ? "android" : "ios";
                  final errorMessage = "$e";
                  await exceptionApiManager.insertExceptionLog(
                    deviceType,
                    "cut story",
                    errorMessage,
                  );
                  await _playController.rollbackCut(rollbackBlocks, totalLength, cutFrom);
                }
              }
              ref.watch(loadingProvider.notifier).state = false;
            },
            borderRadius: BorderRadius.circular(50), // Ensures ripple effect stays within the circle
            splashColor: Colors.white.withOpacity(0.3), // Adjust ripple color
            child: ClipOval( // Ensures the shape is a perfect circle
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/trim_page/trim_end.svg",
                      width: 32.w,
                      height: 32.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      width: 55.w,
                      height: 20.h,
                      child: AutoSizeText(
                        "剪輯結束",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}