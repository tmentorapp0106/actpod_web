import 'package:flutter/material.dart';
import 'package:quick_share_app/components/center_dialog_with_one_button.dart';

class BackgroundPausedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CenterDialogWithOneButton(
        title: "提醒",
        content: "暫時不支援背景處理，請重新進入",
        buttonText: "確認",
        buttonFunction: () {
          Navigator.of(context).pop();
        }
    );
  }
}