import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/time_utils.dart';

class WebAboutStory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Column(
      children: [
        title(storyInfo == null? DateTime.now() : storyInfo.storyUploadTime),
        SizedBox(height: 0.h,),
        description(storyInfo == null? "" : storyInfo.storyDescription)
      ],
    );
  }

  Widget title(DateTime uploadTime) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 120.w
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "關於這則故事",
            style: TextStyle(
                fontSize: 4.w,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(width: 2.w,),
          Text(
            TimeUtils.convertToFormat("yyyy/MM/dd", uploadTime),
            style: TextStyle(
              fontSize: 4.w
            ),
          )
        ],
      )
    );
  }

  Widget description(String description) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 120.h,
        minWidth: 120.w,
        maxWidth: 120.w
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Linkify(
                onOpen: _onOpenDescriptionLink,
                options: const LinkifyOptions(humanize: false),
                text: description,
                style: TextStyle(
                  fontSize: 4.w
                ),
              )
            )
          ]
        ),
      ),
    );
  }

  Future<void> _onOpenDescriptionLink(LinkableElement link) async {
    await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.inAppBrowserView
    );
  }
}