import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/features/voice_message_page_feature/controllers/add_voice_message_dialog_player_controller.dart';

import '../../../../config/color.dart';
import '../../../../dto/voice_message_dto.dart';
import '../../providers.dart';

class PlayerBox extends ConsumerWidget {
  final AddVoiceMessageDialogPlayerController _playerController;
  final VoiceMessageDto _voiceMessageDto;

  PlayerBox(this._playerController, this._voiceMessageDto);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Avatar(_voiceMessageDto.listenerId, _voiceMessageDto.listenerAvatarImageUrl, 30.w),
            SizedBox(width: 5.w,),
            Text(
              _voiceMessageDto.listenerName
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            playStopBtn(ref),
            SizedBox(width: 5.w,),
            SizedBox(
              width: 230.w,
              child: ProgressBar(
                progress: ref.watch(addVoiceMessagePlayerProgressProvider),
                thumbRadius: 5.w,
                barHeight: 4.h,
                thumbColor: ConfigColor.textColorDefault,
                baseBarColor: Colors.grey,
                progressBarColor: Colors.grey,
                total: ref.watch(addVoiceMessageLengthProvider),
                onSeek: (duration) {
                  _playerController.seekPosition(duration);
                },
                timeLabelLocation: TimeLabelLocation.sides,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget playStopBtn(WidgetRef ref) {
    return InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          if(ref.watch(addVoiceMessagePlayerStatusProvider) == "playing") {
            _playerController.pause();
          } else {
            _playerController.play();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: ConfigColor.backgroundThird,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(2.w),
          child: ref.watch(addVoiceMessagePlayerStatusProvider) == "playing" ?
          Icon(
            Icons.pause,
            color: Colors.white,
            size: 18.w
          ) :
          Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 18.w
          ),
        )
    );
  }
}