import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/components/waveform_painter.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/background_music_dto.dart';
import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/background_music_select_screen.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/operate_background_model.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/operate_insert_sound_model.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/operate_sound_effect_model.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/sound_effect_select_modal.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/music_player_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../components/keep_alive_widget.dart';
import '../../../../design_system/design.dart';
import '../../../../providers.dart';
import '../../controllers/edit_trim_player_controller.dart';
import '../../controllers/edit_trim_player_timer_controller.dart';
import '../../../../dto/block_info_dto.dart';
import '../../providers.dart';

class AudioBar extends ConsumerWidget {
  final ScrollController _storyBarScrollController;
  final ScrollController _soundEffectBarScrollController;
  final ScrollController _backgroundBarScrollController;
  final EditTrimPlayerTimerController _playerTimerController;
  final EditTrimPlayController _playController;
  double scrollOffset = 0;
  bool pointerDown = false;


  AudioBar(this._storyBarScrollController, this._soundEffectBarScrollController, this._backgroundBarScrollController, this._playerTimerController, this._playController);

  Future<void> onDragEnd(WidgetRef ref) async {
    if(ref.watch(isSeekingProvider)) {
      return;
    }
    ref.watch(isScrollingProvider.notifier).state = false;
    await _playController.seekPosition((_storyBarScrollController.position.pixels * ref.watch(barScaleProvider)).round(), track: false);
  }

  Future<void> onDragStart(WidgetRef ref) async {
    ref.watch(isScrollingProvider.notifier).state = true;
    await _playController.pauseAudio(); // 一定需要 不然 on position 會繼續更新 造成以為一些 block 已經播過的錯誤
    _playerTimerController.stopTrackingProgress();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Stack(
      children: [
        Container(
          height: 370.h,
          color: DesignSystem.backgroundGrey,
        ),
        IgnorePointer(
          ignoring: ref.watch(isSeekingProvider),
          child: Column(
            children: [
              SizedBox(height: 5.h,),
              SizedBox(
                height: 200.h,
                width: ScreenUtil().screenWidth,
                child: storyBar(ref),
              ),
              SizedBox(height: 10.h,),
              SizedBox(
                height: 70.h,
                width: ScreenUtil().screenWidth,
                child: backgroundMusicBar(ref, context),
              ),
              SizedBox(height: 10.h,),
              SizedBox(
                height: 70.h,
                width: ScreenUtil().screenWidth,
                child: soundEffectBar(ref, context),
              ),
            ],
          )
        ),
        indicator()
      ]
    );
  }

  Widget soundEffectBar(WidgetRef ref, BuildContext context) {
    List<SoundEffectDto> soundEffectList = ref.watch(selectedSoundEffectDtoProvider);
    int itemCount = soundEffectList.length + 2;

    return ListView.builder(
      itemCount: itemCount,
      controller: _soundEffectBarScrollController,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Add left padding container
          return Container(
            width: ScreenUtil().screenWidth / 2,
            height: 70.h,
            color: DesignSystem.backgroundGrey,
          );
        }

        if (index <= soundEffectList.length) {
          int soundEffectIndex = index - 1; // Offset by 1 for the left container
          SoundEffectDto soundEffect = soundEffectList[soundEffectIndex];

          // Calculate blank and playing intervals
          Duration cursor = soundEffectIndex == 0
              ? Duration.zero
              : Duration(milliseconds: soundEffectList[soundEffectIndex - 1].endMilliSec);
          Duration blankInterval = Duration(milliseconds: soundEffect.startMilliSec - cursor.inMilliseconds);
          Duration playingInterval = Duration(milliseconds: soundEffect.endMilliSec - soundEffect.startMilliSec);

          return Row(
            children: [
              // Blank interval
              Container(
                width: blankInterval.inMilliseconds / ref.watch(barScaleProvider),
                height: 50.h,
                color: Colors.transparent,
              ),

              // Playing interval
              InkWell(
                onTap: () {
                  _playController.pauseAudio();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.w),
                      ),
                    ),
                    builder: (context) {
                      return OperateSoundEffectModel(soundEffectIndex, _playController);
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.w),
                    color: Color(0xFFD0A9F9),
                  ),
                  width: playingInterval.inMilliseconds / ref.watch(barScaleProvider),
                  height: 70.h,
                  child: Text(
                    soundEffect.soundEffectName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.w,
                    ),
                  ),
                ),
              ),
            ],
          );
        }


        Duration lastInterval = soundEffectList.isEmpty? ref.watch(totalLengthProvider): ref.watch(totalLengthProvider) - Duration(milliseconds: soundEffectList.last.endMilliSec);
        // Add the right container after sound effect widgets
        return Row(
          children: [
            // Blank interval
            Container(
            width: lastInterval.inMilliseconds / ref.watch(barScaleProvider),
              height: 50.h,
              color: Colors.transparent,
            ),
            Container(
              width: ScreenUtil().screenWidth / 2,
              height: 70.h,
              color: DesignSystem.backgroundGrey,
            )
          ]
        );
      },
    );
  }

  Widget storyBar(WidgetRef ref) {
    List<BlockInfoDto> blocks = ref.watch(blockInfosProvider);
    int itemCount = blocks.length + 2;  // +2 for the containers before and after

    return Listener(
      onPointerDown: (_) {
        pointerDown = true;
        onDragStart(ref);
      },
      onPointerUp: (_) async {
        pointerDown = false;
        if(scrollOffset == _storyBarScrollController.offset) {
          ref.watch(isScrollingProvider.notifier).state = false;
          return;
        }
        while(true) {
          await Future.delayed(Duration(milliseconds: 50));
          if(pointerDown) {
            break;
          }
          if((scrollOffset - _storyBarScrollController.offset).abs() < 0.1) {
            onDragEnd(ref);
            break;
          }
          scrollOffset = _storyBarScrollController.offset;
        }
      },
      child: ListView.builder(
        itemCount: itemCount,
        controller: _storyBarScrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              width: ScreenUtil().screenWidth / 2,
              height: 200.h,
              color: DesignSystem.backgroundGrey,
            );
          }
          if (index <= blocks.length) {
            int blockIndex = index - 1;  // Offset by 1 due to the first container
            if(blocks[blockIndex].type == "story") {
              return storyBlock(blocks[blockIndex], ref);
            } else {
              return insertBlock(blocks[blockIndex], blockIndex, context, ref);
            }
          }
          // Add the right container after waveform widgets
          return Container(
            width: ScreenUtil().screenWidth / 2,
            height: 200.h,
            color: DesignSystem.backgroundGrey,
          );
        },
      )
    );
  }

  Widget storyBlock(BlockInfoDto block, WidgetRef ref) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: DesignSystem.primary500,
        borderRadius: BorderRadius.circular(15.w),
      ),
      width: (block.to - block.from).inMilliseconds / ref.watch(barScaleProvider),
      child: CustomPaint(
        painter: WaveformPainter(
          data: block.waveformData,
          color: Colors.white,
          totalWidth: (block.to - block.from).inMilliseconds / ref.watch(barScaleProvider),
          height: 190.h
        )
      ),
    );
  }

  Widget insertBlock(BlockInfoDto block, int index, BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _playController.pauseAudio();
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
            return OperateInsertSoundModel(index, _playController);
          }
        );
      },
      child: Container(
        height: 200.h,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
        decoration: BoxDecoration(
          color: block.soundType == "soundEffect"? Color(0xFFD0A9F9) : Color(0xff92C8B7),
          borderRadius: BorderRadius.circular(15.w),
        ),
        width: (block.to - block.from).inMilliseconds / ref.watch(barScaleProvider),
        child: Text(
          block.name,
          style: TextStyle(
            color: Colors.white
          ),
        ),
      )
    );
  }

  Widget backgroundMusicBar(WidgetRef ref, BuildContext context) {
    Duration cursor = Duration.zero;
    List<BackgroundMusicDto> backgroundList = ref.watch(selectedBackgroundProvider);
    int itemCount = backgroundList.length + 2; // For left and right padding containers

    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      controller: _backgroundBarScrollController,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            width: ScreenUtil().screenWidth / 2,
            height: 70.h,
            color: DesignSystem.backgroundGrey,
          );
        }

        if (index <= backgroundList.length) {
          int bgMusicIndex = index - 1; // Offset by 1 for the left container
          BackgroundMusicDto backgroundMusic = backgroundList[bgMusicIndex];

          // Calculate blank and playing intervals
          Duration blankInterval = Duration(
              milliseconds: backgroundMusic.startMilliSec - cursor.inMilliseconds);
          Duration playingInterval = Duration(
              milliseconds: backgroundMusic.endMilliSec - backgroundMusic.startMilliSec);

          cursor = Duration(milliseconds: backgroundMusic.endMilliSec);

          return Row(
            children: [
              // blank interval
              Container(
                width: blankInterval.inMilliseconds / ref.watch(barScaleProvider),
                height: 50.h,
                color: Colors.transparent,
              ),
              // Playing interval
              InkWell(
                onTap: () {
                  _playController.pauseAudio();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.w),
                      ),
                    ),
                    builder: (context) {
                      return OperateBackgroundModel(bgMusicIndex, _playController);
                    },
                  );
                },
                child: KeepAliveWidget(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.w),
                      color: Color(0xff92C8B7),
                    ),
                    width: playingInterval.inMilliseconds / ref.watch(barScaleProvider),
                    height: 70.h,
                    child: Text(
                      backgroundMusic.name,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ),
              ),
            ],
          );
        }

        // Add the right padding container after the last interval
        Duration totalLength = ref.watch(totalLengthProvider);
        Duration lastInterval = totalLength - cursor > Duration.zero
            ? totalLength - cursor
            : Duration.zero;

        return Row(
          children: [
            // Blank interval
            Container(
              width: lastInterval.inMilliseconds / ref.watch(barScaleProvider),
              height: 50.h,
              color: Colors.transparent,
            ),
            Container(
              width: ScreenUtil().screenWidth / 2,
              height: 70.h,
              color: DesignSystem.backgroundGrey,
            ),
          ],
        );
      },
    );
  }

  Widget indicator() {
    return Positioned(
      right: ScreenUtil().screenWidth / 2 - 2,
      child: IgnorePointer(
        child: Container(
          width: 2,
          height: 370.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: Colors.white
          ),
        )
      )
    );
  }
}