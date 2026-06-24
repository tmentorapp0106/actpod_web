import 'package:actpod_web/api_manager/purchase_dto/create_credit_card_payment.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/components/invoice_email_dialog.dart';
import 'package:actpod_web/features/package_detail_page/components/package_buttons.dart';
import 'package:actpod_web/features/package_detail_page/components/package_cover.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/utils/neweb_pay_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PackageInfoCard extends ConsumerWidget {
  final PackageInfoWithStoriesItem package;
  final bool compact;
  final PackageDetailController packageDetailController;

  const PackageInfoCard({
    super.key,
    required this.package,
    required this.packageDetailController,
    this.compact = false,
  });

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!AuthService.isLoggedIn()) {
      final bool? loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const LoginScreen();
        },
      );

      if (loggedIn != true || !context.mounted) {
        return;
      }

      await packageDetailController.checkPurchased(package.packageId);
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
      package.packagePrice!.twd,
      "package",
      package.packageId,
      package.packageName,
      invoiceEmail,
    );
    if (response.code != "0000") {
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

  void _handleStartListening(BuildContext context) {
    final firstStory = package.stories.first;
    if (firstStory.storyUrl.trim().isEmpty) {
      ToastService.showNoticeToast("尚未上傳內容");
      return;
    }

    context.push("/story/${firstStory.storyId}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twd = package.packagePrice?.twd;
    final purchased = ref.watch(packagePurchasedProvider);
    final isLoggedIn = AuthService.isLoggedIn();
    final isNotForSale = twd == null || twd < 0;
    final isPurchaseLoading = purchased == null;
    final canPurchase = !isNotForSale && purchased == false;
    final canStartListening = purchased == true && package.stories.isNotEmpty;
    final priceText = isNotForSale ? "--" : twd.toString();
    final buttonText = purchased == true
        ? package.stories.isEmpty
            ? "目前沒有單集"
            : "開始收聽第一集"
        : isNotForSale
            ? "尚未開賣"
            : isLoggedIn
                ? "購買套裝"
                : "前往購買";

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 24),
      decoration: BoxDecoration(
        color: packageSoft,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: packageBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            const PackageBadge(),
            const SizedBox(height: 14),
          ],
          Text(
            package.packageName,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 22 : 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Avatar(package.userId, package.avatarUrl, compact ? 15 : 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  package.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 14),
          _RecruitingBadge(
            compact: compact,
          ),
          if (purchased != true) ...[
            SizedBox(height: compact ? 8 : 12),
            const Text(
              "套裝價",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    color: packageAccent,
                    fontSize: compact ? 38 : 58,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(bottom: compact ? 2 : 8),
                  child: const Text(
                    "新台幣",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          PackagePrimaryButton(
            text: buttonText,
            loading: !isNotForSale && isPurchaseLoading,
            onPressed: canStartListening
                ? () => _handleStartListening(context)
                : canPurchase
                    ? () => _handlePurchase(context, ref)
                    : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RecruitingBadge extends StatelessWidget {
  final bool compact;

  const _RecruitingBadge({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 6,
        vertical: compact ? 2 : 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: packageAccent.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: packageAccent.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: packageAccent,
            size: compact ? 24 : 24,
          ),
          SizedBox(width: compact ? 2 : 4),
          Text(
            "熱烈募集中",
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7A3F00),
            ),
          ),
        ],
      ),
    );
  }
}
