import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/components/whole_page_progress.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/close_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/timer.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/coins_and_cash_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/record_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/controllers/send_controller.dart';
import 'package:quick_share_app/features/send_voice_message_feature/pages/donate_page.dart';
import 'package:quick_share_app/features/send_voice_message_feature/pages/play_page.dart';
import 'package:quick_share_app/features/send_voice_message_feature/pages/purchase_page.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'pages/record_page.dart';
import 'services/send_expend_message_record_service.dart';

class SendVoiceMessageScreen extends ConsumerStatefulWidget {
  final BuildContext dialogContext;
  final PlayerItemDto playerItemDto;

  SendVoiceMessageScreen(this.dialogContext, this.playerItemDto);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SendExpendMessageScreenState(this.dialogContext);
  }
}

class SendExpendMessageScreenState extends ConsumerState<SendVoiceMessageScreen> {
  BuildContext dialogContext;
  SendExpendMessageRecordService? recordService;
  RecorderController recorderController = RecorderController();
  PlayerController playerController = PlayerController();
  RecordController? recordController;
  SendController? sendController;
  CoinsAndCashController? coinsAndCashController;

  SendExpendMessageScreenState(this.dialogContext);

  @override
  void initState() {
    super.initState();
    recordService  = SendExpendMessageRecordService(recorderController, playerController);
    sendController = SendController(ref);
    recordController = RecordController(context, ref, recordService!);
    coinsAndCashController = CoinsAndCashController(ref);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
        initProviders();
        coinsAndCashController!.getCoinList();
        coinsAndCashController!.getUserPurses();
    });
  }

  void initProviders() {
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
    ref.watch(voiceMessageLengthProvider.notifier).state = Duration.zero;
    ref.watch(messageRecordTimerProvider.notifier).state = Duration.zero;
    ref.watch(messagePlayingTimerProvider.notifier).state = Duration.zero;
    ref.watch(donateAmountProvider.notifier).state = 0;
    ref.watch(purchaseAmountProvider.notifier).state = 0;
    ref.watch(isPurchasingProvider.notifier).state = false;
    ref.watch(isSelectingDonationProvider.notifier).state = false;
  }

  @override
  void dispose() {
    recordService!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    final isPurchasing = ref.watch(isPurchasingProvider);
    final isSelectingDonation = ref.watch(isSelectingDonationProvider);
    final sendVoiceMessageStatus = ref.watch(sendVoiceMessageStatusProvider);

    if(isPurchasing) {
      page = PurchasePage();
    } else if (isSelectingDonation) {
      page = DonatePage(
          recordController!,
          sendController!,
          widget.playerItemDto,
          context
      );
    } else if(sendVoiceMessageStatus == "pending" || sendVoiceMessageStatus == "recording") {
      page = RecordPage(
          recordController!,
          sendController!,
          context,
          widget.playerItemDto
      );
    } else if (sendVoiceMessageStatus == "recorded" || sendVoiceMessageStatus == "playing" || sendVoiceMessageStatus == "paused") {
      page = PlayPage(
        widget.playerItemDto,
        recordController!,
        sendController!,
        context
      );
    } else {
      page = const SizedBox.shrink();
    }

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            final sendVoiceMessageStatus = ref.watch(sendVoiceMessageStatusProvider);
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
                page,
                CloseDialogButton()
              ]
            )
          )
        ),
        WholePageProgress(
          percentageProvider: loadingPercentageProvider,
          showProvider: loadingProvider,
          height: MediaQuery.of(context).size.height,
          textColor: Colors.white,
          child: const SizedBox.shrink(), // Empty child to ensure overlay effect
        ),
      ]
    );
  }
}