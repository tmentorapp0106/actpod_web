import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/components/center_dialog.dart';

class DeleteDraftDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "刪除草稿",
      content: "您確定要刪除草稿嗎？",
      leftButtonText: "取消",
      rightButtonText: "確定",
      leftButtonFunction: () {
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () {
        Navigator.of(context).pop(true);
      },
    );
  }
}