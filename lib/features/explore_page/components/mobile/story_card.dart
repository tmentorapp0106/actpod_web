import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';

class MobileStoryCard extends StatelessWidget {
  final StoryInfoDto story;

  const MobileStoryCard({
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        myRouter.push("/story/${story.storyId}");
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                _CoverImage(
                  imageUrl: story.storyImageUrl,
                  size: 122,
                  duration: story.totalLength,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.storyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        _ChannelHeaderMini(story: story),

                        const Spacer(),

                        Text(
                          story.storyDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            _CategoryPill(text: story.spaceName),
                            const SizedBox(width: 8),
                            Text(
                              TimeUtils.convertToFormat("yyyy/MM/dd", story.releaseTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: _PlayCircleButton(
                size: 24,
                iconSize: 16,
              ),
            ),
          ],
        ),
      )
    );
  }
}


class _ChannelHeaderMini extends StatelessWidget {
  final StoryInfoDto story;

  const _ChannelHeaderMini({
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            story.channelImageUrl,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.channelName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Avatar(null, story.userAvatarUrl, 14),
                  const SizedBox(width: 2,),
                  Text(
                    story.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  )
                ] 
              )
            ]
          )
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final int duration;

  const _CoverImage({
    required this.imageUrl,
    required this.size,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                TimeUtils.formatDuration(Duration(milliseconds: duration), "HH:mm:ss"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String text;

  const _CategoryPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF8B5A00),
        ),
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final double size;
  final double iconSize;

  const _PlayCircleButton({
    this.size = 46,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFBC1F),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
