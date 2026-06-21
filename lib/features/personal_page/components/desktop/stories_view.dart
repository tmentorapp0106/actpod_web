import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/components/channel_image.dart';
import 'package:actpod_web/components/content_rating_badge.dart';
import 'package:actpod_web/const.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class DesktopStoriesView extends ConsumerWidget {
  const DesktopStoriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyList = ref.watch(storyListProvider);

    if (storyList == null || storyList.isEmpty) {
      return const _DesktopEmptyView(
        assetName: "assets/images/empty_stories.svg",
        label: "尚無故事",
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 188,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: storyList.length,
      itemBuilder: (context, index) {
        return _DesktopStoryCard(story: storyList[index]);
      },
    );
  }
}

class _DesktopStoryCard extends StatelessWidget {
  final StoryItem story;

  const _DesktopStoryCard({
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        myRouter.push('/story/${story.storyId}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignColor.neutral40),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StoryCover(story: story),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.storyName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChannelImage(
                        story.channelImageUrl,
                        story.channelName,
                        24,
                        14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          story.channelName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ContentRatingBadge(
                    contentRating: story.contentRating,
                    compact: true,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _Metric(
                        icon: Icons.favorite_border_rounded,
                        value: story.likesCount.toString(),
                      ),
                      const SizedBox(width: 12),
                      _Metric(
                        icon: Icons.record_voice_over_outlined,
                        value: story.voiceMessageCount.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(child: _SpacePill(text: story.spaceName)),
                      const SizedBox(width: 10),
                      Text(
                        TimeUtils.dayAgo(story.storyUploadTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        TimeUtils.formatDuration(
                          Duration(milliseconds: story.totalLength),
                          "HH:mm:ss",
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black54,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StoryCover extends StatelessWidget {
  final StoryItem story;

  const _StoryCover({
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imgProxy + story.storyImageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Metric({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _SpacePill extends StatelessWidget {
  final String text;

  const _SpacePill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DesktopEmptyView extends StatelessWidget {
  final String assetName;
  final String label;

  const _DesktopEmptyView({
    required this.assetName,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetName,
            color: Colors.grey,
            width: 120,
            height: 120,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
