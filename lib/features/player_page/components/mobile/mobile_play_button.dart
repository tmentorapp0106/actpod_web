import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../main.dart';
import '../../controllers/player_controller.dart';
import '../../providers.dart';

class MobilePlayButton extends ConsumerWidget {
  final PlayerController playerController;

  MobilePlayButton(this.playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStatusProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(20.w),
      onTap: () async {
        if(playerState == "preparing") {
          return;
        } else if(playerState == "playing") {
          playerController.pause();
        } else {
          playerController.play();
        }
      },
      child: Icon(
        playerState == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: 50.w,
        color: Colors.black,
      )
    );
  }
}