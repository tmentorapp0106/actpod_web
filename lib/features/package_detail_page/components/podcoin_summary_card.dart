import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/features/explore_page/providers.dart'
    as explore_providers;
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _googlePlayUrl =
    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW";
const _appStoreUrl = "https://apps.apple.com/tw/app/actpod/id6468426325";

class PodCoinSummaryCard extends ConsumerWidget {
  final bool compact;
  final PackageDetailController packageDetailController;
  final String packageId;

  const PodCoinSummaryCard(
      {super.key,
      this.compact = false,
      required this.packageDetailController,
      required this.packageId});

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
                await packageDetailController.checkPurchased(packageId);
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
