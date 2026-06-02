import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/components/center_dialog.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../login_feature/login_screen.dart';

class InquireSavingDraftDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "需要儲存草稿嗎？",
      content: "您還沒儲存草稿喔，需要儲存嗎？",
      leftButtonText: "離開",
      rightButtonText: "儲存",
      leftButtonFunction: () {
        Navigator.of(context).pop(false);
      },
      rightButtonFunction: () async {
        if(!UserService.hasLoggedIn()) {
          showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          return;
        }
        Navigator.of(context).pop(true);
      },
    );
  }
}