import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';

import '../../../components/center_dialog.dart';
import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';

class LogoutDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WholePageLoading(
      provider: loadingProvider,
      child: CenterDialog(
        title: "登出",
        content: "確定要登出嗎？",
        leftButtonText: '取消',
        rightButtonText: "確認",
        leftButtonFunction: () {
          Navigator.of(context).pop();
        },
        rightButtonFunction: () async {
          ref.watch(loadingProvider.notifier).state = true;
          await UserService.logoutUser(ref);
          Navigator.of(context).pop();
        },
      )
    );
  }
}