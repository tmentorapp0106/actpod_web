part of 'player_web_screen.dart';

class _WebMediaPanel extends ConsumerWidget {
  final PlayerController playerController;

  const _WebMediaPanel({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playContent = ref.watch(playContentProvider);
    final storyInfo = ref.watch(storyInfoProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: playContent == PlayContent.story
                      ? _WebStoryImage(storyInfo: storyInfo)
                      : _WebInteractiveContent(
                          playerController: playerController,
                        ),
                ),
              ),
              _WebContentSwitch(playerController: playerController),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebStoryImage extends StatelessWidget {
  final GetOneStoryResItem? storyInfo;

  const _WebStoryImage({required this.storyInfo});

  @override
  Widget build(BuildContext context) {
    final imageUrl = storyInfo?.storyImageUrl ?? "";
    if (imageUrl.isEmpty) {
      return Container(
        color: DesignColor.neutral50,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
    );
  }
}

class _WebInteractiveContent extends ConsumerWidget {
  final PlayerController playerController;

  const _WebInteractiveContent({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactiveList = ref.watch(interactiveMessageInfoListProvider);
    final interactiveIndex =
        ref.watch(interactiveMessageInfoIndexProvider) ?? 0;

    if (interactiveList == null) {
      return const Center(
        child: CircularProgressIndicator(color: DesignColor.primary50),
      );
    }

    if (interactiveList.isEmpty) {
      return Container(
        color: DesignColor.neutral50,
        child: const Center(
          child: Text(
            "尚無語音留言",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final activeIndex = interactiveIndex.clamp(0, interactiveList.length - 1);

    return Container(
      color: DesignColor.neutral50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DesignColor.primary50, width: 5),
            ),
            child: Center(
              child: Avatar(
                null,
                interactiveList[activeIndex].avatarUrl,
                164,
              ),
            ),
          ),
          const SizedBox(width: 34),
          SizedBox(
            width: 54,
            height: 260,
            child: ListView.separated(
              itemCount: interactiveList.length,
              itemBuilder: (context, index) {
                final selected = activeIndex == index;
                return GestureDetector(
                  onTap: () {
                    playerController.seekPosition(
                      Duration(
                          milliseconds: interactiveList[index].fromMilliSec),
                    );
                  },
                  child: Container(
                    width: selected ? 52 : 46,
                    height: selected ? 52 : 46,
                    padding: EdgeInsets.all(selected ? 3 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: DesignColor.primary50, width: 3)
                          : null,
                    ),
                    child: Avatar(
                      null,
                      interactiveList[index].avatarUrl,
                      selected ? 46 : 42,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebContentSwitch extends ConsumerWidget {
  final PlayerController playerController;

  const _WebContentSwitch({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playContent = ref.watch(playContentProvider);
    final hasInteractiveContent =
        ref.watch(interactiveMessageInfoListProvider)?.isNotEmpty ?? false;

    if (!hasInteractiveContent) {
      return const SizedBox.shrink();
    }

    final isStory = playContent == PlayContent.story;

    return Positioned(
      bottom: 14,
      right: isStory ? 14 : null,
      left: isStory ? null : 14,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          playerController.playIndex(isStory ? 1 : 0);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isStory)
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              Text(
                isStory ? "語音留言" : "收聽正片",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isStory)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
