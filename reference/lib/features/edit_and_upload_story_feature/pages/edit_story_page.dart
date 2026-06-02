import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/sound_btns.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/upload_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import '../components/edit_story_screen/audio_bar.dart';
import '../components/edit_story_screen/play_stop_button.dart';
import '../components/edit_story_screen/player_timer.dart';
import '../components/edit_story_screen/timer_blocks.dart';
import '../components/edit_story_screen/timer_indicator.dart';
import '../controllers/music_player_controller.dart';
import '../controllers/edit_trim_player_controller.dart';
import '../controllers/edit_trim_player_timer_controller.dart';

class EditStoryPage extends ConsumerWidget {
  final EditTrimPlayerTimerController? _playerTimerController;
  final EditTrimPlayController? _playController;
  final ScrollController? _storyBarScrollController;
  final ScrollController? _soundEffectBarScrollController;
  final ScrollController? _backgroundBarScrollController;
  final ScrollController? _timerIndicatorScrollController;
  final MusicPlayerController? _musicPlayerController;
  final ListController? _listController;
  final UploadController? _uploadController;

  EditStoryPage(
    this._playerTimerController, 
    this._playController, 
    this._storyBarScrollController, 
    this._soundEffectBarScrollController, 
    this._backgroundBarScrollController, 
    this._timerIndicatorScrollController, 
    this._musicPlayerController,
    this._listController,
    this._uploadController,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20.h,),
          PlayerTimer(),
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: ref.watch(showBlocksProvider),
                    child: TimerBlocks(_timerIndicatorScrollController!)
                  ),
                  SizedBox(height: 5.h,),
                  Visibility(
                    visible: ref.watch(showBlocksProvider),
                    child: AudioBar(_storyBarScrollController!, _soundEffectBarScrollController!, _backgroundBarScrollController!, _playerTimerController!, _playController!)
                  ),
                  SizedBox(height: 25.h,),
                  SoundBtns(_playController!, _musicPlayerController!, _storyBarScrollController!, _playerTimerController!, _listController!, _uploadController!),
                ],
              ),
              // TimerIndicator()
            ],
          ),
          SizedBox(height: 30.h,),
          PlayStopButton(_playController!),
          SizedBox(height: 30.h,),
        ],
      )
    );
  }
}