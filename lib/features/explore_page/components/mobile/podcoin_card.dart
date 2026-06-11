import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/explore_page/controllers/story_controller.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodCoinBalanceCard extends ConsumerWidget {
  final StoryController storyController;

  const PodCoinBalanceCard({super.key, required this.storyController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfoDto = ref.watch(userInfoProvider);
    final podCoins = ref.watch(userPodCoinsProvider);

    if (userInfoDto == null) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAEF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFE1A1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return LoginScreen();
                  },
                );
                if(AuthService.isLoggedIn()) {
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE1A1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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

          const SizedBox(height: 14),

          const Text(
            "剩餘的 PodCoin",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                podCoins.toString(),
                style: const TextStyle(
                  fontSize: 32,
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
              PodCoin(size: 48),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: go to top up page
              },
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text(
                "前往儲值",
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
        ],
      ),
    );
  }
}