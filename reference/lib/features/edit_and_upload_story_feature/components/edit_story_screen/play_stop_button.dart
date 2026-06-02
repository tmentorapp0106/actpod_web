import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';

import '../../../../services/toast_service.dart';
import '../../controllers/edit_trim_player_controller.dart';
import '../../providers.dart';

class PlayStopButton extends ConsumerWidget {
  final EditTrimPlayController _playController;

  PlayStopButton(this._playController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatus = ref.watch(playerStatusProvider);

    return playStopBtn(playerStatus, ref);
  }

  Widget playStopBtn(String playerStatus, WidgetRef ref) {
    return InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          print(ref.watch(isScrollingProvider));
          print(ref.watch(isSeekingProvider));
          if(ref.watch(isSeekingProvider) || ref.watch(isScrollingProvider)) {
            return;
          }

          if(!_playController.isRecorded()) {
            ToastService.showNoticeToast("no record");
          }

          if(playerStatus == "pausing") {
            _playController.playAudio();
            return;
          }

          if(playerStatus == "playing") {
            _playController.pauseAudio();
            return;
          }
          _playController.playAudio();
        },
        child: Container(
          decoration: BoxDecoration(
            color: DesignSystem.primary500,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8.w),
          child: playerStatus == "playing"?
          Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 65.w
          ) :
          Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 65.w
          ),
        )
    );
  }
}