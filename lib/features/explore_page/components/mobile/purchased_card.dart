import 'package:actpod_web/api_manager/story_dto/find_user_purchase_records_res.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/const.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';

class MobilePurchasedCard extends StatelessWidget {
  final PurchaseRecordInfoItem record;

  const MobilePurchasedCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final item = _PurchasedRecordView.fromRecord(record);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(22),
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
                  imageUrl: item.imageUrl,
                  size: 122,
                  duration: item.duration,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _ChannelHeaderMini(item: item),
                        const Spacer(),
                        Text(
                          item.description,
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
                            _TypePill(text: item.typeLabel),
                            if (item.spaceName.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                  child: _CategoryPill(text: item.spaceName)),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              TimeUtils.convertToFormat(
                                  "yyyy/MM/dd", item.releaseTime),
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
                onTap: item.onTap,
                size: 24,
                iconSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelHeaderMini extends StatelessWidget {
  final _PurchasedRecordView item;

  const _ChannelHeaderMini({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.channelImageUrl.isNotEmpty
              ? Image.network(
                  item.channelImageUrl,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 28,
                  height: 28,
                  color: const Color(0xFFEDEDED),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            item.channelName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Row(children: [
            Avatar(null, item.avatarUrl, 14),
            const SizedBox(
              width: 2,
            ),
            Text(
              item.creatorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
            )
          ])
        ])),
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
    final hasImage = imageUrl.isNotEmpty;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: hasImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                : Container(color: const Color(0xFFEDEDED)),
          ),
          if (duration > 0)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  TimeUtils.formatDuration(
                      Duration(milliseconds: duration), "HH:mm:ss"),
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

class _TypePill extends StatelessWidget {
  final String text;

  const _TypePill({
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
        color: const Color(0xFFFFBC1F),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _PlayCircleButton({
    required this.onTap,
    this.size = 46,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFBC1F),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
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

class _PurchasedRecordView {
  final bool isPackage;
  final String title;
  final String description;
  final String imageUrl;
  final String channelName;
  final String channelImageUrl;
  final String creatorName;
  final String avatarUrl;
  final String spaceName;
  final int duration;
  final DateTime releaseTime;
  final VoidCallback onTap;

  String get typeLabel => isPackage ? "套裝" : "故事";

  _PurchasedRecordView({
    required this.isPackage,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.channelName,
    required this.channelImageUrl,
    required this.creatorName,
    required this.avatarUrl,
    required this.spaceName,
    required this.duration,
    required this.releaseTime,
    required this.onTap,
  });

  factory _PurchasedRecordView.fromRecord(PurchaseRecordInfoItem record) {
    final package = record.packageInfo;
    final story = record.storyInfo;

    if (package != null) {
      final firstStory =
          package.stories.isNotEmpty ? package.stories.first : null;
      final duration = package.stories.fold<int>(
        0,
        (total, story) => total + story.storyLength,
      );

      return _PurchasedRecordView(
        isPackage: true,
        title: package.packageName,
        description: package.packageDescription,
        imageUrl: _imageUrl(package.packageImageUrl),
        channelName: firstStory?.channelName ?? "",
        channelImageUrl: _imageUrl(firstStory?.channelImageUrl ?? ""),
        creatorName: package.nickname,
        avatarUrl: package.avatarUrl,
        spaceName: firstStory?.spaceName ?? "",
        duration: duration,
        releaseTime: package.createTime,
        onTap: () => myRouter.push("/package/${package.packageId}"),
      );
    }

    return _PurchasedRecordView(
      isPackage: false,
      title: story?.storyName ?? "",
      description: story?.storyDescription ?? "",
      imageUrl: _imageUrl(
        story?.storyImageUrls.isNotEmpty == true
            ? story!.storyImageUrls.first
            : "",
      ),
      channelName: story?.channelName ?? "",
      channelImageUrl: _imageUrl(story?.channelImageUrl ?? ""),
      creatorName: story?.userName ?? "",
      avatarUrl: story?.userAvatarUrl ?? "",
      spaceName: story?.spaceName ?? "",
      duration: story?.totalLength ?? story?.storyLength ?? 0,
      releaseTime: story?.releaseTime ?? record.createTime,
      onTap: () => myRouter.push("/story/${story?.storyId ?? record.storyId}"),
    );
  }
}

String _imageUrl(String url) {
  if (url.isEmpty || url.startsWith("http")) {
    return url;
  }
  return imgProxy + url;
}
