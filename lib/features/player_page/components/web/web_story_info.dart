part of 'player_web_screen.dart';

class _WebStoryInfo extends StatelessWidget {
  final GetOneStoryResItem storyInfo;
  final CollectionController collectionController;

  const _WebStoryInfo({
    required this.storyInfo,
    required this.collectionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          storyInfo.storyName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            ChannelImage(
              storyInfo.channelImageUrl,
              storyInfo.channelName,
              48,
              22,
              radius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storyInfo.channelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _WebUserChip(
                        userId: storyInfo.userId,
                        avatarUrl: storyInfo.avatarUrl,
                        name: storyInfo.nickname,
                      ),
                      if (storyInfo.collaboratorId.isNotEmpty)
                        _WebUserChip(
                          userId: storyInfo.collaboratorId,
                          avatarUrl: storyInfo.collaboratorAvatarUrl,
                          name: storyInfo.collaboratorName,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            CollectButton(collectionController: collectionController),
          ],
        ),
      ],
    );
  }
}

class _WebUserChip extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String name;

  const _WebUserChip({
    required this.userId,
    required this.avatarUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Avatar(userId, avatarUrl, 20),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
