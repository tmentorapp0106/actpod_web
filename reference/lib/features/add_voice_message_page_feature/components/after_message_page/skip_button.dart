import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../../dto/voice_message_dto.dart';
import '../../controllers/after_message_recorder_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/pre_message_recorder_controller.dart';
import '../../providers.dart';

class SkipBtn extends ConsumerWidget {
  final String storyId;
  final String voiceMessageId;
  final PageController _pageController;
  final PlayerController _playerController;
  final AfterMessageRecorderController _afterMessageRecorderController;
  final PreMessageRecorderController _preMessageRecorderController;

  SkipBtn(this.storyId, this.voiceMessageId, this._pageController, this._playerController, this._preMessageRecorderController, this._afterMessageRecorderController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return skipBtn(context, ref);
  }

  Widget skipBtn(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(afterMessageRecordStatusProvider) == "pending",
      child: InkWell(
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
        borderRadius: BorderRadius.circular(30.w),
        child: AutoSizeText(
          "略過",
          style: TextStyle(
            fontSize: 16.w,
            color: ConfigColor.textColorDefault
          )
        ),
      )
    );
  }
}