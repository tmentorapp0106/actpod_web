import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/shared_prefs/agreement_prefs.dart';
import '../../l10n/app_localizations.dart';

import 'center_dialog_with_one_button.dart';

class PolicytAgreementDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: CenterDialogWithOneButton(
        title: "用戶協議",
        content: "1. 接受條款\n使用 ActPod 即表示您同意本用戶許可協議。如果不同意，請勿使用。\n2. 用戶行為\n不得發布非法、攻擊性或濫用性內容。\n不得進行騷擾、欺凌或威脅行為。\n3. 禁止使用\n該應用不得被非法使用或用於損害服務。\n4. 執行\n我們可能會移除有害內容並採取行動，包括終止帳戶。\n5. 報告問題\n通過 ActPod 提供的報告系統報告問題。\n6. 用戶許可協議的變更\n我們可能會更新本用戶許可協議。繼續使用即表示接受新條款。\n\n聯絡方式:\n請通過電子郵件 contact.us@actpodapp.com 聯絡我們。",
        buttonText: "同意",
        buttonFunction: () {
          AgreementPrefs.setContentPolicyAgreement(true);
          Navigator.of(context).pop();
        },
      )
    );
  }
}