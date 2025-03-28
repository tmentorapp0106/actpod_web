import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/player_controller.dart';

class ListenToMessage extends ConsumerWidget {
  final PlayerController _playerController;

  ListenToMessage(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // PlayerItemDto? playerItemDto = ref.watch(miniPlayerStoryInfoProvider);
        // if(playerItemDto!.storyLength == playerItemDto.totalLength) {
        //   ToastService.showNoticeToast("這則故事沒有留言");
        //   return;
        // }
        // _playerController.seekAudioPosition(Duration(milliseconds: playerItemDto.storyLength));
      },
      child: Row(
        children: [
          Image.asset(
            "assets/icons/listen_to_message.png",
            width: 20.w,
            height: 20.w,
            fit: BoxFit.fitWidth,
          ),
          Text(
            "聆聽留言",
            style: TextStyle(
              fontSize: 12.w
            ),
          )
        ],
      )
    );
  }
}