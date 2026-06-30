import 'package:actpod_web/components/content_rating_badge.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/time_utils.dart';

class MobileAboutStory extends ConsumerWidget {
  const MobileAboutStory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Column(
      children: [
        title(
          storyInfo == null ? DateTime.now() : storyInfo.storyUploadTime,
          storyInfo == null ? "" : storyInfo.spaceName,
          storyInfo == null ? "general" : storyInfo.contentRating,
        ),
        SizedBox(
          height: 5.h,
        ),
        description(storyInfo == null ? "" : storyInfo.storyDescription)
      ],
    );
  }

  Widget title(DateTime uploadTime, String spaceName, String rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "關於這則故事",
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 8.w,
        ),
        Text(
          TimeUtils.convertToFormat("yyyy/MM/dd", uploadTime),
          style: TextStyle(fontSize: 12.w),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
              color: DesignColor.neutral100,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            spaceName,
            style: TextStyle(fontSize: 12.w),
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        ContentRatingBadge(
          contentRating: rating,
          compact: true,
        )
      ],
    );
  }

  Widget description(String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _DescriptionCopyButton(description: description),
          SizedBox(height: 4.h),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Row(children: [
              Flexible(
                child: SelectionArea(
                  child: Linkify(
                    onOpen: _onOpenDescriptionLink,
                    options: const LinkifyOptions(humanize: false),
                    text: description,
                    style: TextStyle(fontSize: 14.w),
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _onOpenDescriptionLink(LinkableElement link) async {
    await launchUrl(Uri.parse(link.url), mode: LaunchMode.inAppBrowserView);
  }
}

class _DescriptionCopyButton extends StatelessWidget {
  final String description;

  const _DescriptionCopyButton({required this.description});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      tooltip: "複製描述",
      icon: const Icon(Icons.copy_rounded, size: 18),
      onPressed: description.isEmpty
          ? null
          : () async {
              await Clipboard.setData(ClipboardData(text: description));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("已複製描述")),
                );
              }
            },
    );
  }
}
