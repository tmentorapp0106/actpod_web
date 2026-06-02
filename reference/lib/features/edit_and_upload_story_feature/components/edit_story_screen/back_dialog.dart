import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

import '../../../../components/center_dialog.dart';

class BackDialog extends ConsumerWidget {
  final EditTrimPlayController _playController;

  BackDialog(this._playController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "確定要回到剪輯頁嗎？",
      content: "回到剪輯頁後將會丟失音效編輯",
      leftButtonText: "取消",
      rightButtonText: "確認",
      leftButtonFunction: () {
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () async {
        _playController.clearInsertSoundPlayer();
        ref.watch(blockInfosProvider.notifier).state = [...ref.watch(trimmedBlocksProvider)];
        ref.watch(selectedBackgroundProvider.notifier).state = [];
        ref.watch(selectedSoundEffectDtoProvider.notifier).state = [];
        ref.watch(totalLengthProvider.notifier).state = ref.watch(trimmedBlocksProvider).last.to;
        Navigator.of(context).pop(true);
      },
    );
  }
}