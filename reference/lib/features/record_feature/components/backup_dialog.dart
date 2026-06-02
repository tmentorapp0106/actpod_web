import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/shared_prefs/record_backup_prefs.dart';

import '../../../components/center_dialog.dart';

class BackupDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "使用備份嗎？",
      content: "偵測到上次有遇到異常退出的情形，要使用上次的錄音嗎？",
      leftButtonText: "取消",
      rightButtonText: "使用",
      leftButtonFunction: () async {
        try {
          if(RecordBackupPrefs.getBackupPath() != null) {
            File(RecordBackupPrefs.getBackupPath()!).delete();
          }
        } catch(e) {
          print(e);
        }
        await RecordBackupPrefs.setBackupPath("");
        await RecordBackupPrefs.setBackupWaveformData([]);
        await RecordBackupPrefs.setBackupLength(0);
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () async {
        Navigator.of(context).pop(true);
      },
    );
  }
}