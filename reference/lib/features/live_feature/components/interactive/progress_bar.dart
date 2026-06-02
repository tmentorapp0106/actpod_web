import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';

import '../../../../config/color.dart';
import '../../../../design_system/color.dart';

class LiveProgressBar extends ConsumerWidget {
  final bool isHost;
  final MessageController messageController;

  LiveProgressBar({required this.isHost, required this.messageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(interactiveRoomModeProvider) == InteractiveRoomMode.inactive,
      child: SizedBox(
        width: 332.w,
        height: 32.w,
        child: ProgressBar(
          progress: ref.watch(currentPositionProvider),
          thumbRadius: 6.w,
          barHeight: 4.w,
          thumbColor: DesignColor.primary50,
          baseBarColor: Color(0xFFd6d6d6),
          progressBarColor: DesignColor.primary50,
          total: Duration(milliseconds: ref.watch(storyInfoProvider)?.storyLength?? 0),
          onSeek: (duration) async {
            if(!isHost) {
              return;
            }
            messageController.sendSeekPosition(duration);
          },
          timeLabelLocation: TimeLabelLocation.below,
          timeLabelTextStyle: TextStyle(
              color: ConfigColor.textColorDefault,
              fontSize: 12.sp
          )
        )
      )
    );
  }
}