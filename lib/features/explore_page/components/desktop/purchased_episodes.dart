import 'package:actpod_web/api_manager/story_dto/find_user_purchase_records_res.dart';
import 'package:actpod_web/const.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';

class PurchasedEpisodesPanel extends StatelessWidget {
  final List<PurchaseRecordInfoItem>? items;

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
          const SelectableText(
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
                child: SelectableText(
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
                child: _PurchasedEpisodeTile(record: e),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _PurchasedEpisodeTile extends StatelessWidget {
  final PurchaseRecordInfoItem record;

  const _PurchasedEpisodeTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final item = _PurchasedRecordView.fromRecord(record);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFEDEDED),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectionArea(
                          child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _TypePill(text: item.typeLabel),
                          if (item.channelName.isNotEmpty)
                            SelectionArea(
                              child: Text(
                                item.channelName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (item.duration > 0)
                        SelectableText(
                          TimeUtils.formatDuration(
                            Duration(milliseconds: item.duration),
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
              onTap: item.onTap,
              size: 28,
              iconSize: 20,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFBC1F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PurchasedRecordView {
  final bool isPackage;
  final String title;
  final String imageUrl;
  final String channelName;
  final int duration;
  final VoidCallback onTap;

  String get typeLabel => isPackage ? "套裝" : "故事";

  _PurchasedRecordView({
    required this.isPackage,
    required this.title,
    required this.imageUrl,
    required this.channelName,
    required this.duration,
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
        imageUrl: _imageUrl(package.packageImageUrl),
        channelName: firstStory?.channelName ?? "",
        duration: duration,
        onTap: () => myRouter.push("/package/${package.packageId}"),
      );
    }

    final storyImage = story != null && story.storyImageUrls.isNotEmpty
        ? story.storyImageUrls.first
        : "";

    return _PurchasedRecordView(
      isPackage: false,
      title: story?.storyName ?? "",
      imageUrl: _imageUrl(storyImage),
      channelName: story?.channelName ?? "",
      duration: story?.storyLength ?? 0,
      onTap: () => myRouter.push("/story/${story?.storyId ?? ""}"),
    );
  }
}

String _imageUrl(String url) {
  if (url.isEmpty || url.startsWith("http")) {
    return url;
  }
  return imgProxy + url;
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
