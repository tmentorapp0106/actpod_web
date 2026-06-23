import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopUserInfo extends ConsumerWidget {
  const DesktopUserInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(userInfoProvider);
    final storyCount = ref.watch(storyCountProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColor.neutral40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(userInfo?.userId, userInfo?.avatarUrl, 124),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo?.nickname ?? "未知的使用者",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                _StoryCount(count: storyCount),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 112),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Linkify(
                      onOpen: LinkUtils.onOpenDescriptionLink,
                      options: const LinkifyOptions(humanize: false),
                      text: userInfo?.selfDescription ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      linkStyle: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: DesignColor.primary50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCount extends StatelessWidget {
  final int count;

  const _StoryCount({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          "Stories",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
