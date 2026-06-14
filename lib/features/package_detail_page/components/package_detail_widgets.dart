import 'package:actpod_web/api_manager/purchase_dto/create_credit_card_payment.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/explore_page/providers.dart'
    as explore_providers;
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

const packageAccent = Color(0xFFFFA300);
const packageSoft = Color(0xFFFFFAEF);
const packageBorder = Color(0xFFFFD78A);
const _googlePlayUrl =
    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW";
const _appStoreUrl = "https://apps.apple.com/tw/app/actpod/id6468426325";

class PackageCover extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double badgeSize;

  const PackageCover({
    super.key,
    required this.imageUrl,
    required this.height,
    this.badgeSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFF1CF),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: packageAccent,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 14,
            child: PackageBadge(fontSize: badgeSize),
          ),
        ],
      ),
    );
  }
}

class PackageBadge extends StatelessWidget {
  final double fontSize;

  const PackageBadge({
    super.key,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.65,
        vertical: fontSize * 0.38,
      ),
      decoration: BoxDecoration(
        color: packageAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "套裝",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

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

  void submitNewebPayForm({
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twd = package.packagePrice?.twd;
    final purchased = ref.watch(packagePurchasedProvider);
    final isNotForSale = twd == null || twd < 0;
    final isPurchaseLoading = purchased == null;
    final canPurchase = !isNotForSale && purchased == false;
    final priceText = isNotForSale ? "--" : twd.toString();

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
          const SizedBox(height: 10),
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
          SizedBox(height: compact ? 16 : 24),
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
                padding: EdgeInsets.only(bottom: compact ? 6 : 10),
                child: const Text(
                  "台幣",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PackagePrimaryButton(
            text: isNotForSale ? "尚未開賣" : "購買套裝",
            loading: !isNotForSale && isPurchaseLoading,
            onPressed: canPurchase
                ? () async {
                    if (!AuthService.isLoggedIn()) {
                      bool? loggedIn = await showDialog<bool>(
                        context: context,
                        barrierDismissible:
                            false, // prevent tap outside to close
                        builder: (context) {
                          return const LoginScreen();
                        },
                      );
                      if (loggedIn != null && loggedIn) {}
                      return;
                    }
                    CreateCreditCardPaymentRes response =
                        await purchaseApiManager.createCreditCardPayment(
                            package.packagePrice!.twd,
                            "package",
                            package.packageId,
                            package.packageName,
                            UserPrefs.getUserInfo()!.email
                          );
                    if (response.code != "0000") {
                      return;
                    }
                    submitNewebPayForm(
                        gatewayUrl: response.creditCardPayment!.gatewayURL,
                        merchantID: response.creditCardPayment!.merchantID,
                        tradeInfo: response.creditCardPayment!.tradeInfo,
                        tradeSha: response.creditCardPayment!.tradeSha,
                        version: response.creditCardPayment!.version);
                  }
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class PackagePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const PackagePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? const Color(0xFFD8D8D8) : packageAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD8D8D8),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class PackageOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PackageOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Color(0xFF7D7D7D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class PackageTags extends StatelessWidget {
  final PackageInfoItem package;

  const PackageTags({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => PackageTag(text: tag)).toList(),
    );
  }
}

class PackageTag extends StatelessWidget {
  final String text;

  const PackageTag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F4F4F),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PackageDescriptionSection extends StatelessWidget {
  final PackageInfoWithStoriesItem package;

  const PackageDescriptionSection({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "套裝介紹"),
        const SizedBox(height: 10),
        Text(
          package.packageDescription,
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            fontWeight: FontWeight.w600,
          ),
        ),
        // const SizedBox(height: 14),
        // PackageTags(package: package),
      ],
    );
  }
}

class PackageStoriesSection extends StatelessWidget {
  final PackageInfoWithStoriesItem package;
  final bool compact;

  const PackageStoriesSection({
    super.key,
    required this.package,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFE6E6E6), height: 32),
        const SectionTitle(title: "內容單集"),
        const SizedBox(height: 10),
        if (package.stories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "目前沒有單集",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          ...package.stories.map(
            (story) => PackageStoryRow(
              story: story,
              compact: compact,
            ),
          ),
      ],
    );
  }
}

class PackageStoryRow extends StatelessWidget {
  final PackageStoryInfoItem story;
  final bool compact;

  const PackageStoryRow({
    super.key,
    required this.story,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.storyImageUrls.isNotEmpty
        ? story.storyImageUrls.first
        : story.channelImageUrl;

    return InkWell(
      onTap:
          story.locked ? null : () => context.push("/story/${story.storyId}"),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: compact ? 6 : 10, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA)),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                width: compact ? 64 : 112,
                height: compact ? 48 : 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: compact ? 64 : 112,
                    height: compact ? 48 : 64,
                    color: const Color(0xFFF2F2F2),
                    child: const Icon(Icons.podcasts, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: compact ? 8 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.storyName,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12 : 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    story.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: compact ? 10 : 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        TimeUtils.formatDuration(
                          Duration(seconds: story.storyLength),
                          "HH:mm:ss",
                        ),
                        style: TextStyle(
                          fontSize: compact ? 9 : 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 8 : 14),
            if (story.locked)
              Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: compact ? 22 : 32,
              )
            else
              Container(
                width: compact ? 26 : 42,
                height: compact ? 26 : 42,
                decoration: const BoxDecoration(
                  color: packageAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: compact ? 18 : 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PodCoinSummaryCard extends ConsumerWidget {
  final bool compact;

  const PodCoinSummaryCard({
    super.key,
    this.compact = false,
  });

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("確認登出"),
          content: const Text("確定要登出 ActPod 嗎？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("登出"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await AuthService.logout();
    ref.read(userInfoProvider.notifier).state = null;
    ref.read(userPodCoinsProvider.notifier).state = 0;
    ref.read(packagePurchasedProvider.notifier).state = false;
    ref.read(explore_providers.purchasedStoriesProvider.notifier).state = [];
  }

  Future<void> _showEditDownloadDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "請下載 ActPod 編輯",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StoreDownloadButton(
                imagePath: "assets/images/google_download.png",
                onPressed: () {
                  Navigator.of(context).pop();
                  LinkUtils.openLink(_googlePlayUrl);
                },
              ),
              const SizedBox(height: 10),
              _StoreDownloadButton(
                imagePath: "assets/images/apple_download.png",
                onPressed: () {
                  Navigator.of(context).pop();
                  LinkUtils.openLink(_appStoreUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final podCoins = ref.watch(userPodCoinsProvider);
    final userDescription = user?.selfDescription.trim() ?? "";

    if (user == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 18 : 22,
          vertical: compact ? 14 : 18,
        ),
        decoration: BoxDecoration(
          color: packageSoft,
          borderRadius: BorderRadius.circular(compact ? 10 : 14),
          border: Border.all(color: packageBorder),
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: compact ? 36 : 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return const LoginScreen();
                  },
                );
              },
              icon: Icon(Icons.login, size: compact ? 18 : 20),
              label: Text(
                "登入",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: packageAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 22),
      decoration: BoxDecoration(
        color: packageSoft,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: packageBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(user.userId, user.avatarUrl, compact ? 24 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 15 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (userDescription.isNotEmpty) ...[
            SizedBox(height: compact ? 4 : 8),
            Text(
              userDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5F5F5F),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: compact ? 8 : 12),
          Text(
            compact ? "剩餘的 PodCoin" : "剩餘的 PodCoin:",
            style: TextStyle(
              color: compact ? Colors.black87 : null,
              fontSize: compact ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: compact ? 2 : 0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                podCoins.toString(),
                style: TextStyle(
                  fontSize: compact ? 28 : 34,
                  height: 1,
                  fontWeight: compact ? FontWeight.w900 : FontWeight.w800,
                  letterSpacing: compact ? 1 : 0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 8 : 10),
                child: Text(
                  "PodCoin",
                  style: TextStyle(
                    fontSize: compact ? 15 : 14,
                    fontWeight: compact ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PodCoin(size: compact ? 36 : 42),
            ],
          ),
          SizedBox(height: compact ? 8 : 18),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () {
                _showEditDownloadDialog(context);
              },
              icon: Icon(Icons.edit, size: compact ? 18 : 20),
              label: Text(
                "編輯資訊",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: packageAccent,
                side: const BorderSide(color: packageAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: Icon(Icons.logout, size: compact ? 18 : 20),
              label: Text(
                "登出",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F8F8F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreDownloadButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _StoreDownloadButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 34,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class PackageDetailLoading extends StatelessWidget {
  const PackageDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Center(
        child: CircularProgressIndicator(
          color: packageAccent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class PackageDetailError extends StatelessWidget {
  final String? message;

  const PackageDetailError({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: packageAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                message?.isNotEmpty == true ? message! : "找不到套裝資訊",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go("/explore"),
                child: const Text("回探索頁"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
