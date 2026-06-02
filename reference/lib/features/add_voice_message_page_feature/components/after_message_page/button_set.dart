import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/pre_message_recorder_controller.dart';
import '../../../../components/hold_to_record_button.dart';
import '../../../../providers.dart';
import '../../../../services/toast_service.dart';
import '../../controllers/after_message_recorder_controller.dart';
import '../../providers.dart';

class ButtonSet extends ConsumerWidget {
  final storyId;
  final String voiceMessageId;
  final AfterMessageRecorderController _afterMessageRecorderController;
  final PreMessageRecorderController _preMessageRecorderController;
  final PlayerController _playerController;
  final PageController _pageController;

  ButtonSet(
    this.storyId,
    this.voiceMessageId,
    this._afterMessageRecorderController,
    this._preMessageRecorderController,
    this._playerController,
    this._pageController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ref.watch(afterMessageRecordStatusProvider) == "recorded" || ref.watch(afterMessageRecordStatusProvider) == "pausing"? deleteBtn(ref) : const SizedBox.shrink(),
        SizedBox(width: 20.w,),
        recordPlayBtn(ref),
        SizedBox(width: 20.w,),
        ref.watch(afterMessageRecordStatusProvider) == "recorded" || ref.watch(afterMessageRecordStatusProvider) == "pausing"? checkBtn(ref, context) : const SizedBox.shrink()
      ]
    );
  }

  Widget deleteBtn(WidgetRef ref) {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            _afterMessageRecorderController.resetRecording();
          },
          child:  Padding(
            padding: EdgeInsets.all(10.w),
            child:  SvgPicture.asset(
              "assets/icons/deleteStoryImg.svg",
              width: 18.w,
              height: 18.w,
              color: Colors.black
            ),
          ),
        ),
        Text(
          "刪除",
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ]
    );
  }

  Widget checkBtn(WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            ref.watch(loadingProvider.notifier).state = true;
            _playerController.prepareAudio(
              storyId,
              voiceMessageId,
              _preMessageRecorderController.audioFilePath,
              _afterMessageRecorderController.audioFilePath,
              () {
                _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
              }
            );
          },
          child: Padding(
          padding: EdgeInsets.all(10.w),
            child:Icon(
              Icons.check,
              color: Colors.black,
              size: 20.w
            )
          )
        ),
        Text(
          "完成",
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ]
    );
  }

  Widget recordPlayBtn(WidgetRef ref) {
    final recordStatus = ref.watch(afterMessageRecordStatusProvider);

    if(recordStatus == "pending" || recordStatus == "recording") {
      return HoldToRecordButton(
          onStartRecording: () async {
            _afterMessageRecorderController.startRecord();
          },
          onStopRecording: ({bool canceled = false}) async {
            _afterMessageRecorderController.stopRecord();
          }
      );
    } else {
      return Ink(
        child: Material(
            shape: const CircleBorder(),
            color: DesignColor.primary50,
            child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  if(recordStatus == "recorded") {
                    _afterMessageRecorderController.playAudio();
                  } else if(recordStatus == "playing") {
                    _afterMessageRecorderController.pauseAudio();
                  } else if(recordStatus == "pausing") {
                    _afterMessageRecorderController.restartAudio();
                  }
                },
                child: buttons(ref)
            )
        )
      );
    }
  }

  Widget buttons(WidgetRef ref) {
    String recordStatus = ref.watch(afterMessageRecordStatusProvider);

    if(recordStatus == "pending") {
      return Container(
          width: 76.w,
          height: 76.w,
          padding: EdgeInsets.all(10.w),
          child: Image.asset(
            "assets/icons/mic.png",
            fit: BoxFit.fitWidth,
            color: Colors.white,
          )
      );
    } else if(recordStatus == "recording" || recordStatus == "playing") {
      return SizedBox(
        width: 76.w,
        height: 76.w,
        child: Icon(
            Icons.pause_rounded,
            color: Colors.white,
            size: 56.w
        )
      );
    } else {
      return SizedBox(
        width: 76.w,
        height: 76.w,
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 56.w
          )
        )
      );
    }
  }
}