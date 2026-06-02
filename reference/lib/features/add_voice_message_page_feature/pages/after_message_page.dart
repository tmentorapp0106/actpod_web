import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/components/after_message_page/skip_button.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/player_controller.dart';

import '../../../dto/voice_message_dto.dart';
import '../components/after_message_page/button_set.dart';
import '../components/after_message_page/description.dart';
import '../components/after_message_page/hint_bar.dart';
import '../components/after_message_page/title.dart';
import '../components/after_message_page/wave_forms.dart';
import '../controllers/add_voice_message_controller.dart';
import '../controllers/after_message_recorder_controller.dart';
import '../components/after_message_page/timer.dart';
import '../controllers/pre_message_recorder_controller.dart';

class AfterMessagePage extends ConsumerWidget {
  final AfterMessageRecorderController _afterMessageRecorderController;
  final VoiceMessageDto _voiceMessageDto;
  final PreMessageRecorderController _preMessageRecorderController;
  final PageController _pageController;
  final PlayerController _playerController;

  AfterMessagePage(
    this._afterMessageRecorderController,
    this._voiceMessageDto,
    this._preMessageRecorderController,
    this._pageController,
    this._playerController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AfterMessageTitle(),
          AfterMessageDescription(),
          HintBar(),
          WaveForms(_afterMessageRecorderController),
          Timer(),
          SizedBox(height: 5.h,),
          ButtonSet(
            _voiceMessageDto.storyId,
            _voiceMessageDto.voiceMessageId,
            _afterMessageRecorderController,
            _preMessageRecorderController,
            _playerController,
            _pageController
          ),
          SizedBox(height: 15.h,),
          SkipBtn(
            _voiceMessageDto.storyId,
            _voiceMessageDto.voiceMessageId,
            _pageController,
            _playerController,
            _preMessageRecorderController,
            _afterMessageRecorderController
          ),
          SizedBox(height: 10.h,),
        ]
    );
  }
}