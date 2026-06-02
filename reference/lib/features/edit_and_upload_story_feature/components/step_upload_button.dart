import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/extracted_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/load_file_service.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../dto/block_info_dto.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/upload_controller.dart';

class StepUploadBtn extends ConsumerWidget {
  final PageController _pageController;
  final UploadController _uploadController;
  final EditTrimPlayController _playController;
  final EditTrimPlayerTimerController _playerTimerController;
  final ListController _listController;
  final PreviewPlayerController _previewPlayerController;
  final ExtractedPreviewPlayerController _extractedPreviewPlayerController;

  StepUploadBtn(this._pageController, this._uploadController, this._playController, this._playerTimerController, this._listController, this._previewPlayerController, this._extractedPreviewPlayerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(pagePositionProvider) == 5? uploadBtn(context, ref) : stepBtn(context, ref);
  }

  Widget stepBtn(BuildContext context, WidgetRef ref) {
    String buttonText;
    if(ref.watch(pagePositionProvider) < 2) {
      buttonText = "下一步";
    } else if(ref.watch(pagePositionProvider) == 2) {
      buttonText = "擷取精華片段";
    } else if(ref.watch(pagePositionProvider) == 3) {
      buttonText = "進行上傳設定";
    } else if(ref.watch(pagePositionProvider) == 3) {
      buttonText = "進入預覽畫面";
    } else {
      buttonText = "建立故事";
    }

    return InkWell(
      onTap: () async {
        if(_pageController.page == 0) {
          _playerTimerController.stopTrackingProgress();
          _playController.pauseAudio();
          ref.watch(loadingProvider.notifier).state = true;
          await _playController.seekPosition(0, track: true);
          ref.watch(trimmedBlocksProvider.notifier).state = ref
            .watch(blockInfosProvider)
            .map((block) => BlockInfoDto(
              name: block.name,
              from: block.from,
              to: block.to,
              skip: block.skip,
              length: block.length,
              position: block.position,
              soundIndex: block.soundIndex,
              url: block.url,
              waveformData: block.waveformData,
              volume: block.volume,
              type: block.type,
              soundType: block.soundType
          )).toList();
          ref.watch(showBlocksProvider.notifier).state = false;
        } else if(_pageController.page == 1) {
          _playController.pauseAudio();
        } else if(_pageController.page == 2) {
          if(!_uploadController.validateTitleAndDesc()) {
            ToastService.showNoticeToast("請完成所有輸入");
            return;
          }
          if(_playController.normalizedWavFilePath != null) {
            await _previewPlayerController.prepareStory(_playController.normalizedWavFilePath!, isFromPickedFile: false);
            await _extractedPreviewPlayerController.prepareStory(_playController.normalizedWavFilePath!, isFromPickedFile: false);
          }
        } else if(_pageController.page == 3) {
          if(!_uploadController.validateExtractedPreviewEndPosition()) {
            ToastService.showNoticeToast("請選擇預覽區段");
            return;
          }
        } else if(_pageController.page == 4) {
          if(!_uploadController.validatePodcoinSetting()) {
            ToastService.showNoticeToast("請選擇付費價格");
            return;
          }
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        });
      },
      borderRadius: BorderRadius.circular(ref.watch(pagePositionProvider) < 2? 30.w : 8.w),
      child: Container(
        width: ref.watch(pagePositionProvider) < 2.0? 96.w : 328.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: DesignSystem.primary500,
          borderRadius: BorderRadius.circular(ref.watch(pagePositionProvider) < 2? 30.w : 8.w)
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Center(
          child: AutoSizeText(
            buttonText,
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.black
            )
          ),
        ),
      )
    );
  }

  Widget uploadBtn(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if(!UserService.hasLoggedIn()) {
          showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          return;
        }
        _uploadController.uploadStory();
      },
      borderRadius: BorderRadius.circular(30.w),
      child: Container(
        width: 96.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: DesignSystem.primary500,
          borderRadius: BorderRadius.circular(30.w)
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Center(
          child: AutoSizeText(
            "發布",
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