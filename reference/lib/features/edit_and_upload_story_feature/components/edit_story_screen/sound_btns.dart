import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/music_select_model.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/music_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/upload_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../../../../config/color.dart';
import '../../providers.dart';
import 'sound_effect_select_modal.dart';

class SoundBtns extends ConsumerWidget {
  final EditTrimPlayController _playController;
  final MusicPlayerController _musicPlayerController;
  final ScrollController _scrollController;
  final EditTrimPlayerTimerController _playerTimerController;
  final ListController _listController;
  final UploadController _uploadController;

  SoundBtns(this._playController, this._musicPlayerController, this._scrollController, this._playerTimerController, this._listController, this._uploadController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        music(ref, context),
        SizedBox(width: 30.w,),
        soundEffect(ref, context)
      ],
    );
  }

  Widget soundEffect(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = true;
        _listController.getPersonalSoundAudios();
        _playController.pauseAudio();
        _playerTimerController.stopTrackingProgress();
        await _playController.seekPosition((_scrollController.position.pixels * ref.watch(barScaleProvider)).round(), track: false); // 確保位置正確
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.black,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.w)
              )
          ),
          builder: (context) {
            return SoundEffectSelectModal(_musicPlayerController, _playerTimerController, _playController, _uploadController, _listController);
          }
        );
        await Future.delayed(const Duration(milliseconds: 500));
        ref.watch(loadingProvider.notifier).state = false;
      },
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/icons/record_page/ph_hands-clapping-thin.svg",
            width: 32.w,
            height: 32.w,
            color: Colors.white,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(width: 3.w,),
          AutoSizeText(
            "音效",
            style: TextStyle(
                fontSize: 12.w,
                color: Colors.white
            ),
          )
        ],
      )
    );
  }

  Widget music(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = true;
        _listController.getPersonalMusicAudios();
        _playController.pauseAudio();
        _playerTimerController.stopTrackingProgress();
        await _playController.seekPosition((_scrollController.position.pixels * ref.watch(barScaleProvider)).round(), track: false); // 確保位置正確
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.black,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.w)
            )
          ),
          builder: (context) {
            return MusicSelectModel(_musicPlayerController, _playerTimerController, _playController, _uploadController, _listController);
          }
        );
        await Future.delayed(const Duration(milliseconds: 500));
        ref.watch(loadingProvider.notifier).state = false;
      },
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/icons/record_page/music_cast.svg",
            width: 32.w,
            height: 32.w,
            color: Colors.white,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(width: 3.w,),
          AutoSizeText(
            "音樂",
            style: TextStyle(
              fontSize: 12.w,
              color: Colors.white
            ),
          )
        ],
      )
    );
  }
}