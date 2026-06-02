import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';

import '../providers.dart';
import '../controllers/message_response_player_controller.dart';

class PlayStopButton extends ConsumerWidget {
  final MessageResponsePlayerController _playerController;
  final String audioId;
  final String url;

  PlayStopButton(this._playerController, this.audioId, this.url);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatus = ref.watch(messagePlayerStatusProvider);

    return playStopBtn(ref, playerStatus);
  }

  Widget playStopBtn(WidgetRef ref, String playerStatus) {
    Widget button;
    if(playerStatus == "loading" && ref.watch(focusAudioIdProvider) == audioId) {
      button = SizedBox(
        width: 18.w,
        height: 18.w,
        child: CircularProgressIndicator(
          color: DesignColor.primary50,
          strokeWidth: 1.5
        )
      );
    } else if(playerStatus == "playing" && ref.watch(focusAudioIdProvider) == audioId) {
      button = Container(
        decoration: BoxDecoration(
          color: DesignColor.primary50,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(2.w),
        child: Icon(
            Icons.pause,
            color: Colors.white,
            size: 18.w
        )
      );
    } else {
      button = Container(
          decoration: BoxDecoration(
            color: DesignColor.primary50,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(2.w),
          child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 18.w
          )
      );
    }

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () async {
        if(playerStatus == "playing") {
          _playerController.pause();
          return;
        }

        if(playerStatus == "loading") {
          if(ref.watch(focusAudioIdProvider) == audioId) {
            return;
          } else {
            await _playerController.stop();
            _playerController.playAudio(url, audioId);
          }
        }

        if(ref.watch(focusAudioIdProvider) == audioId) {
          _playerController.resume();
        } else {
          _playerController.playAudio(url, audioId);
        }
      },
      child: button
    );
  }
}