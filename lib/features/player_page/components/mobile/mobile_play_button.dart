import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/service/story_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/player_controller.dart';
import '../../providers.dart';

class MobilePlayButton extends ConsumerWidget {
  final PlayerController playerController;

  const MobilePlayButton(this.playerController, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStatusProvider);

    if (playerState != PlayerStatus.unpaid) {
      return InkWell(
          borderRadius: BorderRadius.circular(20.w),
          onTap: () async {
            if (playerState == PlayerStatus.preparing) {
              return;
            } else if (playerState == PlayerStatus.playing) {
              playerController.pause();
            } else {
              playerController.play();
            }
          },
          child: playerState == PlayerStatus.preparing
              ? Center(
                  child: CircularProgressIndicator(
                    color: DesignColor.primary50,
                    strokeWidth: 2.w,
                  ),
                )
              : Icon(
                  playerState == PlayerStatus.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 50.w,
                  color: DesignColor.primary50,
                ));
    } else {
      return InkWell(
          borderRadius: BorderRadius.circular(20.w),
          onTap: () => createStoryCreditCardPayment(context, ref),
          child: Image.asset(
            "assets/images/podcoins.png",
            width: 50.w,
            height: 50.w,
            fit: BoxFit.fitWidth,
          ));
    }
  }
}
