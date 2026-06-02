import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/donate_page/donate_box.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/donate_page/remain_podcoin.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/send_controller.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../utils/device_utils.dart';
import '../components/donate_page/send_button.dart';
import '../components/donate_page/upper_area.dart';
import '../components/donate_page/play_button.dart';
import '../components/donate_page/player_timer.dart';

class DonatePage extends ConsumerWidget {
  final RecordController recordController;
  final SendController sendController;
  final PlayerItemDto playerItem;
  final BuildContext dialogContext;

  DonatePage(this.recordController, this.sendController, this.playerItem, this.dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        width: 280.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h,),
            UpperArea(),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayButton(recordController),
                SizedBox(width: 8.w,),
                PlayerTimer(),
              ],
            ),
            DonateBox(),
            RemainPodcoin(),
            Divider(),
            SizedBox(height: 8.h,),
            SendButton(sendController, recordController, playerItem, dialogContext),
            SizedBox(height: 12.h,),
          ]
        )
    );
  }
}