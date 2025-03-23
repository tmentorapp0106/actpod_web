import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../controllers/player_controller.dart';

class SendMessageButton extends ConsumerWidget {
  final PlayerController _playerController;

  SendMessageButton(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(ref.watch(miniPlayerStoryInfoProvider)?.voiceMessageStatus);

    return Visibility(
      visible: true,
      // visible: ref.watch(miniPlayerStoryInfoProvider)?.voiceMessageStatus == "enable" && ref.watch(miniPlayerStoryInfoProvider)?.userId != UserService.getUserInfo()?.userId,
      child: InkWell(
        onTap: () async {
          // actPodAudioHandler?.pause();
          // _playerController.checkAndShowVoiceMessageDialog();
        },
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/send_voice_message.svg",
              width: 20.w,
              height: 20.w,
              fit: BoxFit.fitWidth,
            ),
            Text(
              "傳送留言",
              style: TextStyle(
                fontSize: 12.w
              ),
            )
          ]
        )
      )
    );
  }
}