part of 'player_web_screen.dart';

class _WebStoryCard extends ConsumerWidget {
  final CollectionController collectionController;
  final PlayerController playerController;
  final CommentController commentController;
  final FocusNode commentFocusNode;
  final FocusNode instantCommentFocusNode;
  final String storyId;

  const _WebStoryCard({
    required this.collectionController,
    required this.playerController,
    required this.commentController,
    required this.commentFocusNode,
    required this.instantCommentFocusNode,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);

    if (storyInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignShadow.shadow,
      ),
      child: Column(
        children: [
          _WebStoryInfo(
            storyInfo: storyInfo,
            collectionController: collectionController,
          ),
          const SizedBox(height: 16),
          _WebMediaPanel(playerController: playerController),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _WebActionButton(
                icon: Icons.mic_none_rounded,
                text: "跟創作者對話",
                onPressed: () => _openStoryDeepLink(context, storyId),
              ),
              _WebActionButton(
                icon: Icons.bubble_chart_rounded,
                text: "傳送即時留言",
                onPressed: () async {
                  commentController.getInstantComments(storyId);
                  await InstantCommentBottomModel(
                    focusNode: instantCommentFocusNode,
                    commentController: commentController,
                    storyId: storyId,
                    playerController: playerController,
                  ).show(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
