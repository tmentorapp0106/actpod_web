import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/noise_providers.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../../config/color.dart';
import '../../../../design_system/design.dart';

class NoiseModel extends ConsumerWidget {
  final NoisePreviewPlayerController _noisePreviewPlayerController;
  final EditTrimPlayerTimerController _editTrimPlayerTimerController;
  final String audioFilePath;

  NoiseModel(this._noisePreviewPlayerController, this._editTrimPlayerTimerController, this.audioFilePath);

  Future<void> processPreview(WidgetRef ref) async {
    ref.watch(noisePreviewProcessProvider.notifier).state = "processing";
    Duration currentPosition = _editTrimPlayerTimerController.getCursor();
    List<BlockInfoDto> blockInfoList = ref.watch(blockInfosProvider);
    int blockIndex = 0;
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentPosition && blockInfoList[i].to > currentPosition) {
        blockIndex = i;
        break;
      }
    }
    try {
      List<String> trimmedPathList = [];
      Duration maxLength = const Duration(seconds: 10);
      while(maxLength > Duration.zero && blockIndex < blockInfoList.length) {
        // first block
        if(currentPosition != blockInfoList[blockIndex].from) {
          Duration offset = currentPosition - blockInfoList[blockIndex].from;
          Duration actualStoryPosition = blockInfoList[blockIndex].position + offset;
          if(blockInfoList[blockIndex].to - currentPosition > maxLength) {
            String? trimmedPath = await AudioUtils.trimWavAudioSync(filePath: audioFilePath, start: actualStoryPosition, end: actualStoryPosition + const Duration(seconds: 10));
            if(trimmedPath == null) {
              ref.watch(noisePreviewProcessProvider.notifier).state = null;
              return;
            }
            trimmedPathList.add(trimmedPath);
            break;
          } else {
            Duration remainLength = blockInfoList[blockIndex].to - currentPosition;
            String? trimmedPath = await AudioUtils.trimWavAudioSync(filePath: audioFilePath, start: actualStoryPosition, end: actualStoryPosition + remainLength);
            if(trimmedPath == null) {
              ref.watch(noisePreviewProcessProvider.notifier).state = null;
              return;
            }
            maxLength -= remainLength;
            trimmedPathList.add(trimmedPath);
          }
        } else {
          if(blockInfoList[blockIndex].length < maxLength) {
            String? trimmedPath = await AudioUtils.trimWavAudioSync(filePath: audioFilePath, start: blockInfoList[blockIndex].position, end: blockInfoList[blockIndex].position + blockInfoList[blockIndex].length);
            if(trimmedPath == null) {
              ref.watch(noisePreviewProcessProvider.notifier).state = null;
              return;
            }
            maxLength -= blockInfoList[blockIndex].length;
            trimmedPathList.add(trimmedPath);
          } else {
            String? trimmedPath = await AudioUtils.trimWavAudioSync(filePath: audioFilePath, start: blockInfoList[blockIndex].position, end: blockInfoList[blockIndex].position + maxLength);
            if(trimmedPath == null) {
              ref.watch(noisePreviewProcessProvider.notifier).state = null;
              return;
            }
            trimmedPathList.add(trimmedPath);
            break;
          }
        }

        if(blockIndex == blockInfoList.length - 1) {
          break;
        }
        blockIndex++;
        currentPosition = blockInfoList[blockIndex].from;
      }
      String? concatedPath = await AudioUtils.concatAudiosSync(trimmedPathList);
      if(concatedPath == null) {
        ref.watch(noisePreviewProcessProvider.notifier).state = null;
        return;
      }

      String? clearedPath = await AudioUtils.clearNoiseSync(concatedPath, (ref.watch(nfProvider) - 80).toString());
      if(clearedPath == null) {
        ref.watch(noisePreviewProcessProvider.notifier).state = null;
        return;
      }
      await _noisePreviewPlayerController.preparePlayer(clearedPath);

      try {
        await File(concatedPath).delete();
        for(int i = 0; i < trimmedPathList.length; i++) {
          await File(trimmedPathList[i]).delete();
        }
      } catch(e) {
        print(e);
      }
      ref.watch(noisePreviewProcessProvider.notifier).state = "done";
    } catch(e) {
      print(e);
    }
    ref.watch(noisePreviewProcessProvider.notifier).state = "done";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget body;
    if(ref.watch(noisePreviewProcessProvider) == null) {
      body = tuneBars(context, ref);
    } else if(ref.watch(noisePreviewProcessProvider) == "processing") {
      body = processing();
    } else if(ref.watch(noisePreviewProcessProvider) == "done") {
      body = noisePreview(context, ref);
    } else {
      body = processing();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dragBar(),
          SizedBox(height: 10.h,),
          title(),
          SizedBox(height: 10.h,),
          body
        ],
      )
    );
  }

  Widget noisePreview(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 250.h,
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hintText(),
          SizedBox(height: 28.h,),
          progressBar(ref),
          SizedBox(height: 12.h,),
          playBtn(context, ref),
          SizedBox(height: 12.h,),
          okBtn(ref)
        ],
      )
    );
  }

  Widget hintText() {
    return Text(
      "試聽片段為當前秒數後 10 秒",
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.w
      ),
    );
  }

  Widget okBtn(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(noisePreviewProcessProvider.notifier).state = null;
        ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
        ref.watch(noisePreviewPlayerDurationProvider.notifier).state = Duration.zero;
        ref.watch(noisePreviewPlayerLengthProvider.notifier).state = Duration.zero;
      },
      child: Text(
        "返回",
        style: TextStyle(
          fontSize: 16.w,
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget playBtn(BuildContext context, WidgetRef ref) {
    return GestureDetector(
    onTap: () async {
      _noisePreviewPlayerController.playPause();
    },
    child: Icon(
        ref.watch(noisePreviewPlayerStatusProvider) == "playing" ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 40.w,
      ),
    );
  }

  Widget progressBar(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 320.w,
          height: 8.w,
          child: ProgressBar(
            progress: ref.watch(noisePreviewPlayerDurationProvider),
            thumbRadius: 5.w,
            barHeight: 6.h,
            thumbColor: ConfigColor.primaryDefault,
            baseBarColor: ConfigColor.greyDefault,
            progressBarColor: ConfigColor.primaryDefault,
            total: ref.watch(noisePreviewPlayerLengthProvider),
            onSeek: (duration) {
              _noisePreviewPlayerController.seek(duration);
            },
            timeLabelLocation: TimeLabelLocation.sides,
            timeLabelTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp
            )
          )
        )
      ]
    );
  }

  Widget tuneBars(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 250.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          nrText(ref),
          SizedBox(height: 8.h,),
          nrProgressBar(ref),
          SizedBox(height: 24.h,),
          nfText(ref),
          SizedBox(height: 8.h,),
          nfProgressBar(ref),
          SizedBox(height: 40.h,),
          SizedBox(
            width: 280.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cancelBtn(context),
                previewBtn(context, ref),
                confirmBtn(context, ref)
              ],
            ),
          )
        ]
      )
    );
  }

  Widget processing() {
    return SizedBox(
      height: 250.h,
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ConfigColor.primaryDefault
          ),
          SizedBox(height: 12.h),
          Text(
            '處理中...',
            style: TextStyle(
              fontSize: 8.w,
              color: Colors.white
            ),
          ),
        ],
      )
    );
  }

  Widget nfProgressBar(WidgetRef ref) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "-80",
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.white
            ),
          ),
          SizedBox(width: 5.w,),
          SizedBox(
              width: 250.w,
              height: 16.w,
              child: ProgressBar(
                progress: Duration(milliseconds: ref.watch(nfProvider)),
                thumbRadius: 8.w,
                barHeight: 8.h,
                thumbColor: ConfigColor.greyDefault,
                baseBarColor: Colors.white,
                progressBarColor: ConfigColor.greyDefault,
                total: Duration(milliseconds: 60),
                onSeek: (duration) {
                  ref.watch(nfProvider.notifier).state = duration.inMilliseconds;
                },
                timeLabelLocation: TimeLabelLocation.none,
              )
          ),
          SizedBox(width: 5.w,),
          Text(
            "-20",
            style: TextStyle(
                fontSize: 16.w,
                color: Colors.white
            ),
          ),
        ]
    );
  }

  Widget nfText(WidgetRef ref) {
    return Text(
      "噪音音量: ${ref.watch(nfProvider) -80}",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.w
      ),
    );
  }

  Widget nrProgressBar(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "1",
          style: TextStyle(
              fontSize: 16.w,
              color: Colors.white
          ),
        ),
        SizedBox(width: 5.w,),
        SizedBox(
          width: 250.w,
          height: 16.w,
          child: ProgressBar(
            progress: Duration(milliseconds: ref.watch(nrProvider)),
            thumbRadius: 8.w,
            barHeight: 8.h,
            thumbColor: ConfigColor.greyDefault,
            baseBarColor: Colors.white,
            progressBarColor: ConfigColor.greyDefault,
            total: Duration(milliseconds: 96),
            onSeek: (duration) {
              ref.watch(nrProvider.notifier).state = duration.inMilliseconds;
            },
            timeLabelLocation: TimeLabelLocation.none,
          )
        ),
        SizedBox(width: 5.w,),
        Text(
          "97",
          style: TextStyle(
              fontSize: 16.w,
              color: Colors.white
          ),
        ),
      ]
    );
  }

  Widget nrText(WidgetRef ref) {
    return Text(
      "降噪強度: ${ref.watch(nrProvider) + 1}",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.w
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        "噪音處理",
        style: TextStyle(
          fontSize: 16.w,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      )
    );
  }

  Widget dragBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 3.h,
          width: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.grey
          ),
        )
      ]
    );
  }

  Widget cancelBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.w),
          border: Border.all(
            color: const Color(0xff8f8f8f)
          )
        ),
        child: Text(
          "取消",
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
            color: const Color(0xff8f8f8f)
          ),
        ),
      )
    );
  }

  Widget confirmBtn(BuildContext context, WidgetRef ref) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).pop(true);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.w),
            color: DesignSystem.primary500
          ),
          child: Text(
            "套用",
            style: TextStyle(
              fontSize: 16.w,
              fontWeight: FontWeight.bold
            ),
          ),
        )
    );
  }

  Widget previewBtn(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        processPreview(ref);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.w),
          color: DesignSystem.primary500
        ),
        child: Text(
          "試聽",
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }
}