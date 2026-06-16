part of 'player_web_screen.dart';

class _WebAccountButton extends ConsumerWidget {
  final PlayerController playerController;

  const _WebAccountButton({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(null, userInfo.avatarUrl, 28),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              userInfo.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DesignColor.neutral90,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return const LoginScreen();
          },
        );
        final storyInfo = ref.read(storyInfoProvider);
        if (storyInfo?.isPremium ?? false) {
          playerController.checkPaid(storyInfo!.storyId, storyInfo.packageId);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: DesignColor.primary50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Text(
        "登入",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}
