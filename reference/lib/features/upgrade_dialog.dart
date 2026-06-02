import 'package:flutter/material.dart';
import 'package:quick_share_app/services/upgrade_service.dart';

import '../components/center_dialog_with_one_button.dart';

class UpgradeDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: CenterDialogWithOneButton(
          title: "更新通知",
          content: "您的 ActPod 需要更新",
          buttonText: "更新",
          buttonFunction: () {
            UpgradeService.upgrade();
          },
        )
    );
  }
}