import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/add_voice_message_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/after_message_recorder_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/pre_message_recorder_controller.dart';

import '../../../dto/voice_message_dto.dart';
import '../components/confirm_page/add_voice_title.dart';
import '../components/confirm_page/confirm_cancel_btn.dart';
import '../components/confirm_page/confirm_message.dart';
import '../components/confirm_page/player_box.dart';

class ConfirmPage extends ConsumerWidget {
  final VoiceMessageDto _voiceMessageDto;
  final PlayerController _playerController;
  final AddVoiceMessageController _addVoiceMessageController;
  final PreMessageRecorderController _preMessageRecorderController;
  final AfterMessageRecorderController _afterMessageRecorderController;

  ConfirmPage(
    this._voiceMessageDto,
    this._playerController,
    this._addVoiceMessageController,
    this._preMessageRecorderController,
    this._afterMessageRecorderController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15.h,),
        AddVoiceTitle(),
        SizedBox(height: 15.h,),
        PlayerBox(_voiceMessageDto, _playerController),
        SizedBox(height: 15.h,),
        ConfirmMessage(_voiceMessageDto),
        SizedBox(height: 5.h,),
        ConfirmCancelBtn(
          _voiceMessageDto,
          _addVoiceMessageController,
          _preMessageRecorderController,
          _afterMessageRecorderController
        )
      ]
    );
  }
}