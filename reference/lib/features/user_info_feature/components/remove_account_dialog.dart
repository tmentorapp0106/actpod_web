import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/user_api_dto/remove_account_res.dart';
import '../../../components/center_dialog.dart';
import '../../login_feature/login_screen.dart';

class RemoveAccountDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CenterDialog(
      title: "Remove Account",
      content: "Are you sure you want to remove account? After removed the account, you still can retrieve account within 15 days by contact us.",
      leftButtonText: 'Cancel',
      rightButtonText: "Confirm",
      leftButtonFunction: () {
        Navigator.of(context).pop();
      },
      rightButtonFunction: () async {
        RemoveAccountRes result = await userApiManager.removeAccount();
        if(result.code != "0000") {
          ToastService.showNoticeToast(result.message);
          return;
        }
        await UserService.logoutUser(ref);
        ToastService.showSuccessToast("Removed Account");
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPageScreen()));
      },
    );
  }

}