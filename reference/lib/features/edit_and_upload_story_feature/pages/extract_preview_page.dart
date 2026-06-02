import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/extract_preview_page/transition_file.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/extracted_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/transition_controller.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../components/waveform_painter.dart';
import '../../../config/color.dart';
import '../components/stepper_nav.dart';
import '../const/const.dart';
import '../controllers/edit_controller.dart';
import '../controllers/edit_trim_player_controller.dart';
import '../controllers/preview_player_controller.dart';
import '../controllers/preview_player_timer_controller.dart';
import '../providers.dart';

class ExtractPreviewPage extends ConsumerWidget {
  final List<String> secondsOptions = [
    '20秒',
    '40秒',
    '60秒',
  ];
  final double paddingHor = 20.w;
  final ScrollController _scrollController;
  final PreviewPlayerController _previewPlayerController;
  final PreviewPlayerTimerController _previewPlayerTimerController;
  final ExtractedPreviewPlayerController _extractedPreviewPlayerController;
  final TransitionController _transitionController;
  double scrollOffset = 0;
  bool pointerDown = false;

  ExtractPreviewPage(
    this._scrollController,
    this._previewPlayerController,
    this._previewPlayerTimerController,
    this._extractedPreviewPlayerController,
    this._transitionController,
  );

  Future<void> onDragEnd(WidgetRef ref) async {
    if(ref.watch(isSeekingProvider)) {
      return;
    }
    ref.watch(isScrollingProvider.notifier).state = false;
    await _previewPlayerController.seekPosition((_scrollController.position.pixels * extractPreviewScale).round(), track: false);
  }

  Future<void> onDragStart(WidgetRef ref) async {
    ref.watch(isScrollingProvider.notifier).state = true;
    await _previewPlayerController.pauseAudio(); // 一定需要 不然 on position 會繼續更新 造成以為一些 block 已經播過的錯誤
    _previewPlayerTimerController.stopTrackingProgress();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHor, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h,),
            const StepperNav(currentStep: 1),
            SizedBox(height: 20.h,),
            title(ref),
            SizedBox(height: 10.h,),
            dropDown(ref),
            SizedBox(height: 10.h,),
            Text(
              "選擇區段",
              style: TextStyle(
                color: DesignColor.neutral600,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20.h,),
            Row(
              children: [
                playBtnAndTimer(ref),
                const Spacer(),
                extractBtn(ref)
              ],
            ),
            SizedBox(height: 16.h,),
            extractBar(ref, _scrollController),
            SizedBox(height: 16.h,),
            previewSectionText(ref),
            SizedBox(height: 4.h,),
            previewPlayBtnAndTimer(ref),
            SizedBox(height: 8.h,),
            previewBar(ref),
            SizedBox(height: 24.h,),
            TransitionFile(_transitionController)
          ],
        ),
      ),
    );
  }

  Widget extractBtn(WidgetRef ref) {
    return InkWell(
      onTap: () async {
        _previewPlayerController.pauseAudio();
        ref.watch(loadingProvider.notifier).state = true;
        await _extractedPreviewPlayerController.pauseAudio();
        await _extractedPreviewPlayerController.extractPreview(_previewPlayerTimerController.getCursor(), ref.watch(extractedPreviewLengthProvider));
        // await _extractedPreviewPlayerController.seekPosition(0);
        ref.watch(loadingProvider.notifier).state = false;
      },
      child: Container(
        child: Text(
          "確定",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.w,
            color: DesignColor.primary50
          ),
        ),
      ),
    );
  }

  Widget previewSectionText(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(extractedPreviewEndPositionProvider) != Duration.zero,
      child: Row(
        children: [
          Text(
            "精華預覽",
            style: TextStyle(
              color: DesignColor.neutral600,
              fontSize: 12.w,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(width: 5.w,),
          Text(
            "${TimeUtils.formatDuration(ref.watch(extractedPreviewStartPositionProvider), "HH:mm:ss")}-${TimeUtils.formatDuration(ref.watch(extractedPreviewEndPositionProvider), "HH:mm:ss")}",
            style: TextStyle(
              color: DesignColor.neutral600,
              fontSize: 12.w,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      )
    );
  }

  Widget playBtnAndTimer(WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if(ref.watch(previewStoryPlayerStatusProvider) == "playing") {
              _previewPlayerController.pauseAudio();
            } else {
              _previewPlayerController.playAudio();
            }
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignColor.primary50,
            ),
            child: Icon(
              ref.watch(previewStoryPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 15.w,
            ),
          ),
        ),
        SizedBox(width: 5.w,),
        Text(
          "${TimeUtils.formatDuration(ref.watch(previewPageStoryPlayTimerProvider), "HH:mm:ss")}/${TimeUtils.formatDuration(ref.watch(totalLengthProvider), "HH:mm:ss")}",
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ],
    );
  }

  Widget previewPlayBtnAndTimer(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(extractedPreviewEndPositionProvider) != Duration.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if(ref.watch(extractedPreviewPlayerStatusProvider) == "playing") {
                _extractedPreviewPlayerController.pauseAudio();
              } else {
                _extractedPreviewPlayerController.playAudio();
              }
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignColor.primary50
                  // border: Border.all()
              ),
              child: Icon(
                ref.watch(extractedPreviewPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 15.w,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 5.w,),
          Text(
            "${TimeUtils.formatDuration(ref.watch(extractedPreviewPlayTimerProvider) + ref.watch(extractedPreviewStartPositionProvider), "HH:mm:ss")}/${TimeUtils.formatDuration(ref.watch(extractedPreviewEndPositionProvider), "HH:mm:ss")}",
            style: TextStyle(
                fontSize: 12.w
            ),
          )
        ],
      )
    );
  }

  Widget previewBar(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(extractedPreviewEndPositionProvider) != Duration.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        height: 8.w,
        child: ProgressBar(
          progress: ref.watch(extractedPreviewPlayTimerProvider),
          thumbRadius: 4.w,
          barHeight: 3.h,
          thumbColor: DesignColor.primary50,
          baseBarColor: ConfigColor.greyDefault,
          progressBarColor: ConfigColor.textColorDefault,
          total: ref.watch(extractedPreviewLengthProvider),
          onSeek: (duration) {
            _extractedPreviewPlayerController.seekPosition(duration.inMilliseconds + ref.watch(extractedPreviewStartPositionProvider).inMilliseconds);
          },
          timeLabelLocation: TimeLabelLocation.none,
          // timeLabelPadding: 4.h,
          timeLabelTextStyle: TextStyle(
            color: ConfigColor.textColorDefault,
            fontSize: 12.sp
          )
        )
      )
    );
  }

  Widget title(WidgetRef ref) {
    return Row(
      children: [
        Text(
          "預覽精華秒數",
          style: TextStyle(
            color: DesignColor.neutral600,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 2.w,),
        infoButton(ref),
        SizedBox(width: 2.w,),
        info(ref)
      ]
    );
  }

  Widget extractBar(WidgetRef ref, ScrollController scrollController) {
    Duration previewLength = ref.watch(extractedPreviewLengthProvider);

    final waveformWidth = ref.watch(totalLengthProvider).inMilliseconds / extractPreviewScale;
    final List<Widget> dividers = [];
    final List<Widget> times = [];

    // Calculate divider positions every 10 seconds
    for (int i = 1; i < ref.watch(totalLengthProvider).inSeconds / 10; i++) {
      final position = i * 10000 / extractPreviewScale; // Position in pixels for each 10-second interval

      // Add vertical divider
      dividers.add(
        Positioned(
          left: position,
          child: Container(
            height: 50.h,
            width: 1.5.w,
            color: Colors.black,
          )
        ),
      );

      times.add(
        Positioned(
          left: position,
          bottom: 8.h,
          child: Text(
            TimeUtils.formatDuration(Duration(milliseconds: i * 10000), "mm:ss")
          ),
        )
      );
    }

    return Stack(
      children: [
        Listener(
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
          child:SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child:  Row(
              children: [
                Container(width: ScreenUtil().screenWidth / 2 - paddingHor - previewLength.inMilliseconds / 2 / extractPreviewScale, height: 90.h,color: Colors.white,),
                Container(
                  width: ref.watch(totalLengthProvider).inMilliseconds / extractPreviewScale,
                  height: 75.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.w),
                    border: Border.all()
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Divider(
                          thickness: 1.5.w,
                          color: Colors.black,
                        )
                      ),
                      ...dividers,
                      ...times
                    ]
                  )
                ),
                Container(width: ScreenUtil().screenWidth / 2 - paddingHor - previewLength.inMilliseconds / 2 / extractPreviewScale, height: 90.h,color: Colors.white,),
              ],
            ),
          ),
        ),
        Center(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: DesignColor.primary50,
                  width: 2
                ),
                borderRadius: BorderRadius.circular(10.w)
              ),
              width: previewLength.inMilliseconds / extractPreviewScale,
              height: 90.h,
            )
          ),
        )
      ],
    );
  }

  Widget infoButton(WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.watch(infoTagProvider.notifier).state = !ref.watch(infoTagProvider);
      },
      customBorder: const CircleBorder(),
      child: Icon(
        ref.watch(infoTagProvider)? Icons.info_rounded : Icons.info_outlined,
        size: 16.w,
      )
    );
  }

  Widget info(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(infoTagProvider),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.w),
          color: Colors.grey
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        child: Text(
          "預覽精華將在首頁播放",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.w
          ),
        ),
      ),
    );
  }

  Widget dropDown(WidgetRef ref) {
    String value;
    Duration selectedLength = ref.watch(extractedPreviewLengthProvider);
    if(selectedLength == const Duration(seconds: 20)) {
      value = secondsOptions[0];
    } else if(selectedLength == const Duration(seconds: 40)) {
      value = secondsOptions[1];
    } else {
      value = secondsOptions[2];
    }

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          isDense: true
        // Add more decoration..
      ),
      value: value,
      hint: const Text(
        '選擇秒數',
        style: TextStyle(fontSize: 14),
      ),
      items: secondsOptions.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      )).toList(),
      validator: (value) {
        if (value == null) {
          return '';
        }
        return null;
      },
      onChanged: (value) {
        if(value == secondsOptions[0]) {
          ref.watch(extractedPreviewLengthProvider.notifier).state = const Duration(seconds: 20);
        } else if(value == secondsOptions[1]) {
          ref.watch(extractedPreviewLengthProvider.notifier).state = const Duration(seconds: 40);
        } else {
          ref.watch(extractedPreviewLengthProvider.notifier).state = const Duration(seconds: 60);
        }
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}