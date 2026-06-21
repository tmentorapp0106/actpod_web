import 'package:actpod_web/const.dart';
import 'package:actpod_web/components/content_rating_badge.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';

class StoryUiModel {
  final String title;
  final String description;
  final String channelName;
  final String channelAvatarUrl;
  final String coverUrl;
  final String category;
  final String date;
  final String duration;
  final int comments;
  final int shares;
  final int likes;

  StoryUiModel({
    required this.title,
    required this.description,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.coverUrl,
    required this.category,
    required this.date,
    required this.duration,
    required this.comments,
    required this.shares,
    required this.likes,
  });
}

class StoryCardDesktop extends StatelessWidget {
  final StoryInfoDto story;

  const StoryCardDesktop({required this.story});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          myRouter.push("/story/${story.storyId}");
        },
        child: Container(
          height: 248,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDEDED)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Row(
                children: [
                  _CoverImage(
                    imageUrl: imgProxy + story.storyImageUrl,
                    size: 192,
                    duration: story.totalLength,
                    contentRating: story.contentRating,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      // 右邊預留播放按鈕空間，避免文字或 metrics 被蓋住
                      padding: const EdgeInsets.only(right: 72),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChannelUserInfo(
                            channelImageUrl: story.channelImageUrl,
                            channelName: story.channelName,
                            avatarUrl: story.userAvatarUrl,
                            nickname: story.channelName,
                          ),
                          const SizedBox(height: 8),
                          SelectionArea(
                              child: Text(
                            story.storyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          )),
                          const SizedBox(height: 8),
                          SelectionArea(
                              child: Text(
                            story.storyDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          )),
                          const Spacer(),
                          Row(
                            children: [
                              _CategoryPill(text: story.spaceName),
                              const SizedBox(width: 8),
                              SelectableText(
                                TimeUtils.convertToFormat(
                                    "yyyy/MM/dd", story.releaseTime),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              _Metric(
                                icon: Icons.chat_bubble_outline,
                                value: "${story.commentCount}",
                              ),
                              const SizedBox(width: 8),
                              _Metric(
                                icon: Icons.favorite_border,
                                value: "${story.likesCount}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: _PlayCircleButton(),
              ),
            ],
          ),
        ));
  }
}

class _ChannelUserInfo extends StatelessWidget {
  final String channelImageUrl;
  final String channelName;
  final String avatarUrl;
  final String nickname;

  const _ChannelUserInfo({
    required this.channelImageUrl,
    required this.channelName,
    required this.avatarUrl,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            channelImageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectionArea(
                  child: Text(
                channelName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const SizedBox(height: 6),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SelectionArea(
                        child: Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final int duration;
  final String contentRating;

  const _CoverImage({
    required this.imageUrl,
    required this.size,
    required this.duration,
    required this.contentRating,
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
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: ContentRatingBadge(
              contentRating: contentRating,
              compact: true,
              overlay: true,
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
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(999),
              ),
              child: SelectableText(
                TimeUtils.formatDuration(
                    Duration(milliseconds: duration), "HH:mm:ss"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
  final bool compact;

  const _CategoryPill({
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8B5A00),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool small;

  const _Metric({
    required this.icon,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: small ? 15 : 17, color: Colors.black45),
        const SizedBox(width: 4),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: small ? 12 : 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final double size;
  final double iconSize;

  const _PlayCircleButton({
    this.size = 52,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFFFBC1F),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
