import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/bottom_area.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/change_voice.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/indication_text.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/recorder_player_timer.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/upper_area.dart';
import 'package:quick_share_app/features/voice_message_page_feature/service/record_service.dart';

import '../../../../components/whole_page_loading.dart';
import '../../../../components/whole_page_progress.dart';
import '../../../../config/color.dart';
import '../../../../dto/voice_message_dto.dart';
import '../../../../providers.dart';
import '../../../../services/toast_service.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/send_controller.dart';
import '../../providers.dart';
import 'close_button.dart';

class ResponseDialogScreen extends ConsumerStatefulWidget {
  final BuildContext dialogContext;
  final VoiceMessageDto voiceMessageDto;

  ResponseDialogScreen(this.dialogContext, this.voiceMessageDto);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ResponseDialogScreenState(this.dialogContext);
  }
}

class ResponseDialogScreenState extends ConsumerState<ResponseDialogScreen> {
  BuildContext dialogContext;
  RecordService? recordService;
  RecorderController recorderController = RecorderController();
  PlayerController playerController = PlayerController();
  RecordController? recordController;
  SendController? sendController;

  ResponseDialogScreenState(this.dialogContext);

  @override
  void initState() {
    super.initState();
    recordService  = RecordService(recorderController, playerController);
    sendController = SendController(ref);
    recordController = RecordController(ref, recordService!);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    recordService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            final sendVoiceMessageStatus = ref.watch(responseStatusProvider);
            if(sendVoiceMessageStatus == "uploading") {
              ToastService.showNoticeToast("uploading...");
              return false;
            }
            return true;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: ConfigColor.background,
            child: Stack(
              children:[
                SizedBox(
                  width: 280.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12.h,),
                      UpperArea(),
                      SizedBox(height: 20.h),
                      const RecorderPlayerTimer(),
                      SizedBox(height: 20.h),
                      BottomArea(recordController!, sendController!, dialogContext, widget.voiceMessageDto),
                      ChangeVoiceCheckBox(),
                      ref.watch(responseStatusProvider) == "pending" || ref.watch(responseStatusProvider) == "recording" ? IndicationText() : const SizedBox.shrink(),
                      SizedBox(height: 15.h,),
                    ]
                  )
                ),
                CloseDialogButton()
              ]
            )
          )
        ),
        WholePageProgress(
          percentageProvider: loadingPercentageProvider,
          showProvider: loadingProvider,
          textColor: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: const SizedBox.shrink(),
        ),
      ]
    );
  }
}