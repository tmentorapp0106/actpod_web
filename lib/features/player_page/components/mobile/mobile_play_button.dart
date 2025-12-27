import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/features/player_page/components/unlock_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../main.dart';
import '../../controllers/player_controller.dart';
import '../../providers.dart';

class MobilePlayButton extends ConsumerWidget {
  final PlayerController playerController;

  MobilePlayButton(this.playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStatusProvider);

    if(playerState != PlayerStatus.unpaid) {
      return InkWell(
        borderRadius: BorderRadius.circular(20.w),
        onTap: () async {
          if(playerState == PlayerStatus.preparing) {
            return;
          } else if(playerState == PlayerStatus.playing) {
            playerController.pause();
          } else {
            playerController.play();
          }
        },
        child: playerState == PlayerStatus.preparing? Center(
          child: CircularProgressIndicator(
              color: DesignColor.primary50,
              strokeWidth: 2.w,
            ),
          ) : Icon(
          playerState == PlayerStatus.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 50.w,
          color: DesignColor.primary50,
        )
      );
    } else {
      return InkWell(
        borderRadius: BorderRadius.circular(20.w),
        onTap: () async {
          if(kIsWeb) {
            bool? goto = await showDialog<bool>(
              context: context,
              builder: (context) => UnlockDialog()
            );
            if(goto != null && goto) {
              await Future.delayed(const Duration(microseconds: 500));
              String url = "https://actpod-488af.web.app/story/link/${ref.watch(storyStateProvider)?.storyId}?openExternalBrowser=1";
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            }
          }
        },
        child: Image.asset(
          "assets/images/podcoins.png",
          width: 50.w,
          height: 50.w,
          fit: BoxFit.fitWidth,
        )
      );
    }
  }
}