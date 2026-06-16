import 'package:actpod_web/api_manager/purchase_dto/create_credit_card_payment.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_widgets.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

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
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoginScreen();
      },
    );
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

  _submitNewebPayForm(
    gatewayUrl: response.creditCardPayment!.gatewayURL,
    merchantID: response.creditCardPayment!.merchantID,
    tradeInfo: response.creditCardPayment!.tradeInfo,
    tradeSha: response.creditCardPayment!.tradeSha,
    version: response.creditCardPayment!.version,
  );
}

void _submitNewebPayForm({
  required String gatewayUrl,
  required String merchantID,
  required String tradeInfo,
  required String tradeSha,
  required String version,
}) {
  final form = html.FormElement()
    ..method = 'POST'
    ..action = gatewayUrl;

  void addInput(String name, String value) {
    final input = html.InputElement()
      ..type = 'hidden'
      ..name = name
      ..value = value;
    form.children.add(input);
  }

  addInput('MerchantID', merchantID);
  addInput('TradeInfo', tradeInfo);
  addInput('TradeSha', tradeSha);
  addInput('Version', version);

  html.document.body!.append(form);
  form.submit();
}
