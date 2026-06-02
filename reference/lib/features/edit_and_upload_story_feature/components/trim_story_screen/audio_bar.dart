import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/waveform_painter.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/providers.dart';

import '../../controllers/edit_trim_player_controller.dart';
import '../../controllers/edit_trim_player_timer_controller.dart';
import '../../../../dto/block_info_dto.dart';
import '../../providers.dart';

class AudioBar extends ConsumerWidget {
  final ScrollController _scrollController;
  final EditTrimPlayerTimerController _playerTimerController;
  final EditTrimPlayController _playController;
  double scrollOffset = 0;
  bool pointerDown = false;


  AudioBar(this._scrollController, this._playerTimerController, this._playController);

  Future<void> onDragEnd(WidgetRef ref) async {
    if(ref.watch(isSeekingProvider)) {
      return;
    }
    ref.watch(isScrollingProvider.notifier).state = false;
    await _playController.seekPosition((_scrollController.position.pixels * ref.watch(barScaleProvider)).round(), track: false);
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
          height: 200.h,
          color: DesignSystem.backgroundGrey,
        ),
        IgnorePointer(
          ignoring: ref.watch(isSeekingProvider),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 200.h,
                    width: ScreenUtil().screenWidth,
                    child: storyBar(ref),
                  ),
                  // SizedBox(height: 20.h,),
                ],
              ),
              cutRange(ref),
              indicator()
            ]
          )
        )
      ],
    );
  }

  Widget storyBar(WidgetRef ref) {
    List<BlockInfoDto> tracks = ref.watch(blockInfosProvider);
    int itemCount = tracks.length + 2;  // +2 for the containers before and after

    return Listener(
      onPointerDown: (_) {
        pointerDown = true;
        onDragStart(ref);
      },
      onPointerUp: (_) async {
        pointerDown = false;
        if(scrollOffset == _scrollController.offset) {
          ref.watch(isScrollingProvider.notifier).state = false;
          return;
        }
        while(true) {
          await Future.delayed(Duration(milliseconds: 50));
          if(pointerDown) {
            break;
          }
          if((scrollOffset - _scrollController.offset).abs() < 0.1) {
            onDragEnd(ref);
            break;
          }
          scrollOffset = _scrollController.offset;
        }
      },
      child: ListView.builder(
        itemCount: itemCount,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              width: ScreenUtil().screenWidth / 2,
              color: DesignSystem.backgroundGrey,
            );
          }
          if (index <= tracks.length) {
            int trackIndex = index - 1;  // Offset by 1 due to the first container
            return Container(
              decoration: BoxDecoration(
                color: DesignSystem.primary500,
                borderRadius: BorderRadius.circular(15.w),
              ),
              width: (tracks[trackIndex].to - tracks[trackIndex].from).inMilliseconds / ref.watch(barScaleProvider),
              child: CustomPaint(
                painter: WaveformPainter(
                  data: tracks[trackIndex].waveformData,
                  color: Colors.white,
                  barWidth: 2.w,
                  totalWidth: (tracks[trackIndex].to - tracks[trackIndex].from).inMilliseconds / ref.watch(barScaleProvider),
                  height: 190.h,
                ),
              ),
            );
          }
          // Add the right container after waveform widgets
          return Container(
            width: ScreenUtil().screenWidth / 2,
            color: DesignSystem.backgroundGrey,
          );
        },
      )
    );
  }

  Widget cutRange(WidgetRef ref) {
    if(ref.watch(cutToProvider) == null || ref.watch(cutFromProvider) == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: ScreenUtil().screenWidth / 2,
      child: IgnorePointer(
        child: Container(
          width: (ref.watch(cutToProvider)! - ref.watch(cutFromProvider)!).inMilliseconds / ref.watch(barScaleProvider),
          height: 200.h,
          color: Colors.black.withOpacity(0.4),
        )
      )
    );
  }

  Widget indicator() {
    return Positioned(
      right: ScreenUtil().screenWidth / 2 - 2,
      child: IgnorePointer(
        child: Container(
          width: 2,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: Colors.white
          ),
        )
      )
    );
  }
}