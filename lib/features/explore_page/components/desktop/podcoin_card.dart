import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/explore_page/controllers/story_controller.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodCoinCard extends ConsumerWidget {
  final StoryController storyController;

  const PodCoinCard({required this.storyController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfoDto = ref.watch(userInfoProvider);

    if (userInfoDto == null) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAEF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFF0C7)),
        ),
        child: Center(
          child: SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return LoginScreen();
                  }
                );
                if(AuthService.isLoggedIn()) {
                  storyController.getPurchasedStories();
                }
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                "登入",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBC1F),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFF0C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(userInfoDto.userId, userInfoDto.avatarUrl, 20),
              const SizedBox(width: 4),
              Text(
                userInfoDto.nickname,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "剩餘的 PodCoin:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w200,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ref.watch(userPodCoinsProvider).toString(),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "PodCoin",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PodCoin(size: 42),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text(
                "前往儲值",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBC1F),
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