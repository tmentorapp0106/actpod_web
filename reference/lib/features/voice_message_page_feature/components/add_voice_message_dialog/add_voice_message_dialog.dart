import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/add_voice_message_dialog/add_voice_title.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/add_voice_message_dialog/confirm_message.dart';
import 'package:quick_share_app/providers.dart';

import '../../../../components/whole_page_progress.dart';
import '../../../../config/color.dart';
import '../../../../dto/voice_message_dto.dart';
import '../../controllers/add_voice_message_dialog_player_controller.dart';
import 'confirm_cancel_btn.dart';
import 'player_box.dart';

class AddVoiceMessageDialogScreen extends ConsumerStatefulWidget {
  final BuildContext dialogContext;
  final VoiceMessageDto voiceMessageDto;

  AddVoiceMessageDialogScreen(this.dialogContext, this.voiceMessageDto);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AddVoiceMessageDialogScreenState(this.dialogContext);
  }
}

class AddVoiceMessageDialogScreenState extends ConsumerState<AddVoiceMessageDialogScreen> {
  BuildContext dialogContext;
  AddVoiceMessageDialogPlayerController? addVoiceMessageDialogPlayerController;

  AddVoiceMessageDialogScreenState(this.dialogContext);

  @override
  void initState() {
    super.initState();
    addVoiceMessageDialogPlayerController = AddVoiceMessageDialogPlayerController(ref, widget.voiceMessageDto);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
        addVoiceMessageDialogPlayerController!.prepareVoiceMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: ConfigColor.background,
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15.h,),
            AddVoiceTitle(),
            SizedBox(height: 15.h,),
            PlayerBox(addVoiceMessageDialogPlayerController!, widget.voiceMessageDto),
            SizedBox(height: 15.h,),
            ConfirmMessage(widget.voiceMessageDto),
            SizedBox(height: 5.h,),
            ConfirmCancelBtn(widget.voiceMessageDto)
          ]
        )
      )
    );
  }
}