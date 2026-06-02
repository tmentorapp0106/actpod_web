import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/components/center_dialog.dart';

class InquireSaveAudioFileDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "儲存音檔？",
      content: "需要儲存調整過後的音檔嗎？",
      leftButtonText: "取消",
      rightButtonText: "儲存",
      leftButtonFunction: () {
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () async {
        Navigator.of(context).pop(true);
      },
    );
  }
}