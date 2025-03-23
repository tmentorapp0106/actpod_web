import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/time_utils.dart';

class AboutStory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        title(DateTime.now()),
        SizedBox(height: 5.h,),
        description("Description")
      ],
    );
  }

  Widget title(DateTime uploadTime) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "關於這則故事",
          style: TextStyle(
              fontSize: 16.w,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 5.w,),
        Text(
          TimeUtils.convertToFormat("yyyy/MM/dd", uploadTime),
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ],
    );
  }

  Widget description(String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      constraints: BoxConstraints(
        maxHeight: 160.h
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Flexible(
              child: Linkify(
                onOpen: _onOpenDescriptionLink,
                options: const LinkifyOptions(humanize: false),
                text: description,
                style: TextStyle(
                  fontSize: 14.w
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