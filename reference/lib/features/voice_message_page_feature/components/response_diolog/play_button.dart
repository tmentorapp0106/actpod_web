import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../controllers/record_controller.dart';
import '../../providers.dart';


class PlayButton extends ConsumerWidget {
  final RecordController recordController;

  PlayButton(this.recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRecordingStatus = ref.watch(responseStatusProvider);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ConfigColor.primaryDefault
      ),
      child: GestureDetector(
        onTap: () {
          if(messageRecordingStatus == "playing") {
            recordController.pauseAudio();
          } else if(messageRecordingStatus == "pausing") {
            recordController.restartAudio();
          } else {
            recordController.playAudio();
          }
        },
        child: Icon(
          messageRecordingStatus == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 65.w
        )
      )
    );
  }

}