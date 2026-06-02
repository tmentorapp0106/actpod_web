import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/play_page/hint_block.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/play_page/hint_text.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/play_page/play_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/play_page/player_timer.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/send_controller.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../utils/device_utils.dart';
import '../components/play_page/cancel_continue.dart';
import '../components/play_page/upper_area.dart';

class PlayPage extends ConsumerWidget {
  final PlayerItemDto playerItemDto;
  final RecordController recordController;
  final SendController sendController;
  final BuildContext dialogContext;

  PlayPage(this.playerItemDto, this.recordController, this.sendController, this.dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        width: 280.w,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h,),
              UpperArea(playerItemDto.userId == UserService.getUserInfo()?.userId),
              Visibility(
                visible: playerItemDto.userId != UserService.getUserInfo()?.userId,
                child: SizedBox(height: 20.h)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayButton(recordController),
                  SizedBox(width: 8.w,),
                  PlayerTimer(),
                ],
              ),
              HintText(playerItemDto.userId == UserService.getUserInfo()?.userId),
              const Divider(),
              Visibility(
                visible: playerItemDto.userId == UserService.getUserInfo()?.userId,
                child: HintBlock(),
              ),
              CancelContinue(
                recordController,
                sendController,
                playerItemDto,
                dialogContext
              )
            ]
        )
    );
  }
}