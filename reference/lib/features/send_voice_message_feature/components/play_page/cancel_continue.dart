import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/send_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

class CancelContinue extends ConsumerWidget {
  final RecordController recordController;
  final SendController sendController;
  final PlayerItemDto playerItemDto;
  final BuildContext dialogContext;

  CancelContinue(this.recordController, this.sendController, this.playerItemDto, this.dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancel(),
          SizedBox(width: 20.w,),
          Visibility(
            visible: playerItemDto.userId != UserService.getUserInfo()?.userId,
            child: continueWidget(ref)
          ),
          Visibility(
              visible: playerItemDto.userId == UserService.getUserInfo()?.userId,
              child: addWidget(ref)
          ),
        ],
      )
    );
  }

  Widget addWidget(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await sendController.sendDirectVoiceMessage(
            recordController.audioFilePath!,
            playerItemDto.storyId,
        );

        if(dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
        decoration: BoxDecoration(
            color: ConfigColor.primaryDefault,
            borderRadius: BorderRadius.circular(20.w),
            border: Border.all(
              color: ConfigColor.primaryDefault,
            )
        ),
        child: Text(
          "添加",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w
          ),
        ),
      ),
    );
  }

  Widget continueWidget(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        recordController.pauseAudio();
        ref.watch(isSelectingDonationProvider.notifier).state = true;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: ConfigColor.primaryDefault,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: ConfigColor.primaryDefault,
          )
        ),
        child: Text(
          "繼續",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w
          ),
        ),
      ),
    );
  }

  Widget cancel() {
    return GestureDetector(
      onTap: () async {
        await recordController.stopAudio();
        recordController.resetRecording();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: const Color(0xff8f8f8f),
          )
        ),
        child: Text(
          "重錄",
          style: TextStyle(
            color: const Color(0xff8f8f8f),
            fontSize: 16.w
          ),
        ),
      ),
    );
  }
}