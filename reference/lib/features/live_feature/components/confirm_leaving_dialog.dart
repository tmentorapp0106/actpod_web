import 'package:flutter/material.dart';
import 'package:quick_share_app/components/center_dialog.dart';

class ConfirmLeavingDialog {
  Future<bool?> show(
      BuildContext context,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (dialogContext) {
        return CenterDialog(
          title: "離開直播間",
          content: "您確定要離開房間嗎？",
          leftButtonText: '取消',
          rightButtonText: '確認',
          leftButtonFunction: () {
            Navigator.of(context).pop(false);
          },
          rightButtonFunction: () {
            Navigator.of(context).pop(true);
          }
        );
      },
    );
  }
}