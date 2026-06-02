import 'package:flutter/material.dart';

import '../../../../components/center_dialog.dart';

class DeleteDialog {
  final BuildContext context;

  DeleteDialog(this.context);

  Future<bool?> show() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return CenterDialog(
          title: "確定要刪除頻道嗎？",
          content: "注意！\n刪除頻道後，頻道所含之故事也會隨之刪除",
          leftButtonText: '取消',
          leftButtonFunction: () {
            Navigator.of(context).pop(false);
          },
          rightButtonText: "確認",
          rightButtonFunction: () {
            Navigator.of(context).pop(true);
          },
        );
      }
    );
  }
}