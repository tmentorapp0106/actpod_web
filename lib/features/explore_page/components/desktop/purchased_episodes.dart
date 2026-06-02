import 'package:actpod_web/const.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';

class PurchasedEpisodesPanel extends StatelessWidget {
  final List<StoryInfoDto>? items;

  const PurchasedEpisodesPanel({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = items == null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "已購買的付費 Podcast",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          if (isLoading)
            const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFBC1F),
                ),
              ),
            )
          else if (items!.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  "尚未購買任何付費 Podcast",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ...items!.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PurchasedEpisodeTile(item: e),
              ),
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _PurchasedEpisodeTile extends StatelessWidget {
  final StoryInfoDto item;

  const _PurchasedEpisodeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imgProxy + item.storyImageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Leave space on the right for play button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.storyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      TimeUtils.formatDuration(
                        Duration(milliseconds: item.totalLength),
                        "HH:mm:ss",
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
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
            onTap: () {},
            size: 28,
            iconSize: 20,
          ),
        ),
      ],
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _PlayCircleButton({
    required this.onTap,
    this.size = 52,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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