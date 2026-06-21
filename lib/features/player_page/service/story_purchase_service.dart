import 'package:actpod_web/api_manager/purchase_dto/create_credit_card_payment.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/components/invoice_email_dialog.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/neweb_pay_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> createStoryCreditCardPayment(
  BuildContext context,
  WidgetRef ref,
) async {
  final story = ref.read(storyInfoProvider);
  final price = story?.price;
  if (story == null || price == null || price.twd < 0) {
    return;
  }

  if (!AuthService.isLoggedIn()) {
    final loggedIn = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoginScreen();
      },
    );

    if (loggedIn != true || !AuthService.isLoggedIn()) {
      return;
    }
  }

  await PlayerController(ref).checkPaid(story.storyId, story.packageId);
  if (ref.read(playerStatusProvider) != PlayerStatus.unpaid) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  final invoiceEmail = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return InvoiceEmailDialog(
        initialEmail: UserPrefs.getUserInfo()?.email ?? "",
      );
    },
  );

  if (invoiceEmail == null) {
    return;
  }

  CreateCreditCardPaymentRes response =
      await purchaseApiManager.createCreditCardPayment(
    price.twd,
    "story",
    story.storyId,
    story.storyName,
    invoiceEmail,
  );
  if (response.code != "0000" || response.creditCardPayment == null) {
    return;
  }

  submitNewebPayForm(
    gatewayUrl: response.creditCardPayment!.gatewayURL,
    merchantID: response.creditCardPayment!.merchantID,
    tradeInfo: response.creditCardPayment!.tradeInfo,
    tradeSha: response.creditCardPayment!.tradeSha,
    version: response.creditCardPayment!.version,
  );
}
