part of 'player_web_screen.dart';

class _WebAboutCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    return _WebSideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "關於這則故事",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Text(
                TimeUtils.convertToFormat(
                  "yyyy/MM/dd",
                  storyInfo?.storyUploadTime ?? DateTime.now(),
                ),
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if ((storyInfo?.spaceName ?? "").isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DesignColor.neutral100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                storyInfo!.spaceName,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Linkify(
            onOpen: (link) async {
              await launchUrl(
                Uri.parse(link.url),
                mode: LaunchMode.inAppBrowserView,
              );
            },
            options: const LinkifyOptions(humanize: false),
            text: storyInfo?.storyDescription ?? "",
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF303030),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _WebStatItem(
                icon: Icons.favorite_border_outlined,
                label:
                    ref.watch(storyStateProvider)?.likeCount.toString() ?? "0",
              ),
              const SizedBox(width: 16),
              _WebStatItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: ref.watch(storyStateProvider)?.commentCount.toString() ??
                    "0",
              ),
              const Spacer(),
              Text(
                "收聽次數：${storyInfo?.count ?? 0}",
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebStatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WebStatItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF777777)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _WebCommentCard extends ConsumerWidget {
  final CommentController commentController;
  final FocusNode focusNode;

  const _WebCommentCard({
    required this.commentController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyStat = ref.watch(storyStateProvider);
    final showedComment = storyStat?.showedComment;

    return _WebSideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "文字留言",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: storyStat == null
                ? null
                : () {
                    commentController.getComments(storyStat.storyId);
                    CommentBottomModel(
                      commentController: commentController,
                      focusNode: focusNode,
                    ).show(
                      context,
                      storyStat.storyId,
                      UserPrefs.getUserInfo()?.userId,
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DesignColor.neutral50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: storyStat == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DesignColor.primary50,
                      ),
                    )
                  : showedComment == null
                      ? const Text(
                          "尚無文字留言",
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(
                              showedComment.userId,
                              showedComment.avatarUrl,
                              36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    showedComment.nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    showedComment.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSideCard extends StatelessWidget {
  final Widget child;

  const _WebSideCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignShadow.shadow,
      ),
      child: child,
    );
  }
}
