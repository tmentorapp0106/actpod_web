import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../dto/player_item_dto.dart';
import '../../../utils/device_utils.dart';
import '../components/record_page/bottom_area.dart';
import '../components/record_page/change_voice.dart';
import '../components/record_page/indication_text.dart';
import '../components/record_page/timer.dart';
import '../components/record_page/upper_area.dart';
import '../controllers/record_controller.dart';
import '../controllers/send_controller.dart';
import '../providers.dart';

class RecordPage extends ConsumerWidget {
  final RecordController recordController;
  final SendController sendController;
  final BuildContext dialogContext;
  final PlayerItemDto playerItemDto;

  RecordPage(this.recordController, this.sendController, this.dialogContext, this.playerItemDto);

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
          SizedBox(height: 20.h),
          const Timer(),
          SizedBox(height: DeviceUtils.isTablet(MediaQuery.of(context))? 40.h : 12.h),
          SendMessageBottomArea(recordController, sendController, dialogContext, playerItemDto),
          SizedBox(height: 10.h,),
          ChangeVoiceCheckBox(),
          ref.watch(sendVoiceMessageStatusProvider) == "pending" || ref.watch(sendVoiceMessageStatusProvider) == "recording" ? IndicationText() : const SizedBox.shrink(),
          SizedBox(height: 16.h,),
        ]
      )
    );
  }
}