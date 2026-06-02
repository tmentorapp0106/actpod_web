import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/player_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';

import '../../../../../design_system/color.dart';

class PlayerButtons extends ConsumerWidget {
  final MessageController messageController;
  final PlayerController playerController;

  PlayerButtons(this.messageController, this.playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        rewindBtn(),
        const SizedBox(width: 36,),
        playBtn(ref),
        const SizedBox(width: 36,),
        fastForwardBtn()
      ]
    );
  }

  Widget fastForwardBtn() {
    return GestureDetector(
      onTap: () {
        Duration position = playerController.getCurrentPosition();
        int newPosition = position.inMilliseconds + 15000;
        messageController.sendSeekPosition(Duration(milliseconds: newPosition));
      },
      child: SvgPicture.asset(
        "assets/icons/forward_15.svg",
        width: 32.w,
        height: 32.w,
        color: DesignColor.neutral70,
      )
    );
  }

  Widget rewindBtn() {
    return GestureDetector(
      onTap: () {
        Duration position = playerController.getCurrentPosition();
        int newPosition = position.inMilliseconds - 15000;
        if(newPosition < 0) {
          newPosition = 0;
        }
        messageController.sendSeekPosition(Duration(milliseconds: newPosition));
      },
      child: SvgPicture.asset(
        "assets/icons/backward_15.svg",
        width: 32.w,
        height: 32.w,
        color: DesignColor.neutral70,
      )
    );
  }

  Widget playBtn(WidgetRef ref) {
    final isPlaying = ref.watch(podcastPlayerStatusProvider);
    return GestureDetector(
      onTap: () {
        if(isPlaying == PodcastPlayerStatus.playing) {
          messageController.sendPausePodcast();
        } else {
          messageController.sendPlayPodcast();
        }
      },
      child: Container(
        width: 40.w, // adjust size as needed
        height: 40.w,
        decoration: const BoxDecoration(
          color: DesignColor.primary50, // or Color(0xFFFFC107) for consistent yellow
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying == PodcastPlayerStatus.playing? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 32.w,
          color: Colors.white,
        ),
      )
    );
  }
}