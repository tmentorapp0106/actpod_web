import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/add_voice_message_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/after_message_recorder_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/pre_message_recorder_controller.dart';

import '../../../../dto/voice_message_dto.dart';
import '../../../add_voice_message_page_feature/add_voice_message_page_screen.dart';
import '../../providers.dart';

class ConfirmCancelBtn extends ConsumerWidget {
  final VoiceMessageDto voiceMessageDto;
  final AddVoiceMessageController addVoiceMessageController;
  final PreMessageRecorderController preMessageRecorderController;
  final AfterMessageRecorderController afterMessageRecorderController;

  ConfirmCancelBtn(
    this.voiceMessageDto,
    this.addVoiceMessageController,
    this.preMessageRecorderController,
    this.afterMessageRecorderController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            borderRadius: BorderRadius.circular(20.w),
            child: Container(
              width: 120.w,
              height: 32.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                border: Border.all(color: Colors.black)
              ),
              child: Center(
                child: Text(
                  "取消",
                  style: TextStyle(
                    fontSize: 16.w
                  ),
                )
              )
            )
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(20.w),
            onTap: () async {
              if(ref.watch(concatedMessageFilePath) == null) {
                return;
              }
              await addVoiceMessageController.send(
                ref.watch(concatedMessageFilePath)!,
                preMessageRecorderController.audioFilePath,
                afterMessageRecorderController.audioFilePath
              );
              Navigator.of(context).pop();
            },
            child: Container(
              width: 120.w,
              height: 32.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey
              ),
              child: Center(
                child: Text(
                  "確定",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.w
                  ),
                )
              )
            )
          ),
        ],
      )
    );
  }
}