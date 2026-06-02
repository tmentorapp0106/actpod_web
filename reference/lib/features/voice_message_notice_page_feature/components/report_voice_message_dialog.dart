import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apiManagers/report_api_dto/create_report_res.dart';
import '../../../apiManagers/report_system_api_manager.dart';
import '../../../components/report_dialog.dart';
import '../../../services/toast_service.dart';
import '../../../shared_prefs/user_prefs.dart';

class ReportVoiceMessageDialog extends ConsumerWidget {
  final TextEditingController textController = TextEditingController();
  final String? suspectsId;

  ReportVoiceMessageDialog(this.suspectsId);

  Future<void> _sendReport() async {
    CreateReportRes res = await reportApiManager.createReport(UserPrefs.getUserInfo()!.userId, suspectsId!, "voiceMessage", textController.text);
    if(res.code != "0000") {
      ToastService.showNoticeToast(res.message);
      return;
    }
    ToastService.showSuccessToast("Voice Message reported!");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportDialog(
      title: "Report Voice Message",
      sendFunction: () {
        _sendReport();
        Navigator.of(context).pop();
      },
      textController: textController,
    );
  }
}