import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/center_dialog.dart';

class ConfirmLeavingDialog extends ConsumerWidget {
  final String? audioFilePath;
  final bool skipEditPage;

  ConfirmLeavingDialog(this.audioFilePath, this.skipEditPage);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "確定要離開嗎？",
      content: skipEditPage? "期待您下次的上傳！" : "離開前記得儲存草稿喔！",
      leftButtonText: "取消",
      rightButtonText: "離開",
      leftButtonFunction: () {
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () async {
        Navigator.of(context).pop(true);
        if(audioFilePath == null) {
          return;
        }
        if (await File(audioFilePath!).exists()) {
          try {
            await File(audioFilePath!).delete();
          } catch (e) {
            print("Error deleting file: $e");
          }
        } else {
          print("File does not exist: $audioFilePath");
        }
      },
    );
  }
}