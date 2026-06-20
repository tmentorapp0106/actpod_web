import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PackageStoriesSection extends ConsumerWidget {
  final PackageInfoWithStoriesItem package;
  final bool compact;

  const PackageStoriesSection({
    super.key,
    required this.package,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchased = ref.watch(packagePurchasedProvider) == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFE6E6E6), height: 32),
        const SectionTitle(title: "內容單集"),
        const SizedBox(height: 10),
        if (package.stories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "目前沒有單集",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          ...package.stories.map(
            (story) => PackageStoryRow(
              story: story,
              purchased: purchased,
              compact: compact,
            ),
          ),
      ],
    );
  }
}

class PackageStoryRow extends StatelessWidget {
  final StoryInfoItem story;
  final bool purchased;
  final bool compact;

  const PackageStoryRow({
    super.key,
    required this.story,
    required this.purchased,
    this.compact = false,
  });

  Future<void> _showNotPurchasedAlert(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "尚未購買",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            "請先購買套裝後再收聽此單集。",
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "確認",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleTap(BuildContext context) {
    if (!purchased) {
      _showNotPurchasedAlert(context);
      return;
    }

    if (story.storyUrl.trim().isEmpty) {
      ToastService.showNoticeToast("尚未上傳內容");
      return;
    }

    context.push("/story/${story.storyId}");
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.storyImageUrls.isNotEmpty
        ? story.storyImageUrls.first
        : story.channelImageUrl;
    final packageNote = story.packageNote.trim();

    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: compact ? 6 : 10, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA)),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                width: compact ? 64 : 112,
                height: compact ? 48 : 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: compact ? 64 : 112,
                    height: compact ? 48 : 64,
                    color: const Color(0xFFF2F2F2),
                    child: const Icon(Icons.podcasts, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: compact ? 8 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.storyName,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12 : 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    story.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (packageNote.isNotEmpty) ...[
                    SizedBox(height: compact ? 4 : 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 8,
                        vertical: compact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        packageNote,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 13,
                          height: 1.35,
                          color: const Color(0xFF6B4B12),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: compact ? 10 : 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        TimeUtils.formatDuration(
                          Duration(seconds: story.storyLength),
                          "HH:mm:ss",
                        ),
                        style: TextStyle(
                          fontSize: compact ? 9 : 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 8 : 14),
            if (!purchased)
              Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: compact ? 22 : 32,
              )
            else
              Container(
                width: compact ? 26 : 42,
                height: compact ? 26 : 42,
                decoration: const BoxDecoration(
                  color: packageAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: compact ? 18 : 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
