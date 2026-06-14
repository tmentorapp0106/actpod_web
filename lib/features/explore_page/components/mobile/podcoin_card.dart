import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/explore_page/controllers/story_controller.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _googlePlayUrl =
    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW";
const _appStoreUrl = "https://apps.apple.com/tw/app/actpod/id6468426325";

class PodCoinBalanceCard extends ConsumerWidget {
  final StoryController storyController;

  const PodCoinBalanceCard({super.key, required this.storyController});

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
    ref.read(purchasedStoriesProvider.notifier).state = [];
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
    final UserInfoDto? userInfoDto = ref.watch(userInfoProvider);
    final podCoins = ref.watch(userPodCoinsProvider);
    final userDescription = userInfoDto?.selfDescription.trim() ?? "";

    if (userInfoDto == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAEF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFE1A1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return const LoginScreen();
                  },
                );
                if (AuthService.isLoggedIn()) {
                  storyController.getPurchasedStories();
                }
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                "登入",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFFBC1F),
                foregroundColor: Colors.white,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE1A1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                userInfoDto.userId,
                userInfoDto.avatarUrl,
                24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userInfoDto.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (userDescription.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              userDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5F5F5F),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            "剩餘的 PodCoin",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                podCoins.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "PodCoin",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              PodCoin(size: 36),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () {
                _showEditDownloadDialog(context);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                "編輯資訊",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFA300),
                side: const BorderSide(color: Color(0xFFFFBC1F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                "登出",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF8F8F8F),
                foregroundColor: Colors.white,
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
