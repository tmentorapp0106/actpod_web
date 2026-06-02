import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/trim_story_screen/cancel_btn.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/trim_story_screen/noise_btn.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/trim_story_screen/player_timer.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/trim_story_screen/restore_btn.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';

import '../components/trim_story_screen/audio_bar.dart';
import '../components/trim_story_screen/cut_button.dart';
import '../components/trim_story_screen/play_stop_button.dart';
import '../components/trim_story_screen/timer_blocks.dart';
import '../controllers/edit_trim_player_controller.dart';
import '../controllers/edit_trim_player_timer_controller.dart';

class TrimPage extends ConsumerWidget {
  final EditTrimPlayerTimerController? _playerTimerController;
  final EditTrimPlayController? _editTrimPlayController;
  final ScrollController? _storyBarScrollController;
  final ScrollController? _timerIndicatorScrollController;
  final EditController? _editController;
  final NoisePreviewPlayerController? _noisePreviewPlayerController;

  TrimPage(
    this._playerTimerController,
    this._editTrimPlayController,
    this._storyBarScrollController,
    this._timerIndicatorScrollController,
    this._editController,
    this._noisePreviewPlayerController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          PlayerTimer(),
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.h,
                    width: ScreenUtil().screenWidth,
                    child: TimerBlocks(_timerIndicatorScrollController!),
                  ),
                  SizedBox(height: 10.h,),
                  SizedBox(
                    width: ScreenUtil().screenWidth,
                    child: AudioBar(_storyBarScrollController!, _playerTimerController!, _editTrimPlayController!)
                  ),
                  SizedBox(height: 30.h,),
                ],
              ),
              // TimerIndicator()
            ],
          ),
          SizedBox(height: 20.h,),
          CutAndVolumeButton(_playerTimerController!, _editTrimPlayController!),
          SizedBox(height: 40.h,),
          NoiseProcessBtn(_editController!, _noisePreviewPlayerController!, _editTrimPlayController!, _playerTimerController!),
          SizedBox(height: 40.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RestoreBtn(_editTrimPlayController!),
              SizedBox(width: 20.w,),
              PlayStopButton(_editTrimPlayController!),
              SizedBox(width: 20.w,),
              CancelBtn()
            ],
          ),
          const Spacer(),
          SizedBox(height: 20.h,)
        ],
      )
    );
  }
}