import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/services/user_service.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../controllers/player_controller.dart';
import '../providers.dart';

class SendMessageButton extends ConsumerWidget {
  final PlayerController playerController;
  final PlayerItemDto storyInfo;

  SendMessageButton({required this.playerController, required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Visibility(
      visible: storyInfo.voiceMessageStatus == "enable",
      child: Expanded(
        child: Material(
          color: Colors.transparent, // need a Material ancestor for ripples
          child: InkWell(
            borderRadius: BorderRadius.circular(10.w),
            splashFactory: InkRipple.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.pressed)
                  ? DesignColor.actpodPrimary500.withOpacity(0.10)
                  : null,
            ),
            onTap: () async {
              await actPodAudioHandler?.pause();
              playerController.checkAndShowVoiceMessageDialog();
            },
            child: Ink( // Ink paints decoration so ripple is clipped correctly
              decoration: BoxDecoration(
                border: Border.all(color: DesignColor.actpodPrimary500),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: SizedBox(
                height: 32.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/voice_message.svg",
                      color: DesignColor.actpodPrimary500,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      storyInfo.userId == UserService.getUserInfo()?.userId? "添加語音" : "語音對話",
                      style: TextStyle(
                        color: DesignColor.actpodPrimary500,
                        fontSize: 14.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}