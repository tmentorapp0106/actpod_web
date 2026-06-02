import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/utils/time_utils.dart';
import 'package:readmore/readmore.dart';

import '../../../design_system/color.dart';
import '../../../utils/link_utils.dart';

class ChannelDesc extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelInfo = ref.watch(channelInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "關於這個頻道",
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 8.w,),
            Text(
              TimeUtils.convertToFormat("yyyy/MM/dd", channelInfo == null? DateTime.now() : channelInfo.createTime),
              style: TextStyle(
                fontSize: 12.w,
              ),
            )
          ]
        ),
        ReadMoreText(
          channelInfo?.channelDescription == null? "" : channelInfo!.channelDescription,
          textAlign: TextAlign.start,
          trimMode: TrimMode.Line,
          trimLines: 2,
          trimCollapsedText: '展開更多',
          trimExpandedText: '\n隱藏顯示',
          moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
          lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
          annotations: [
            // URL
            Annotation(
              regExp: RegExp(
                r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
              ),
              spanBuilder: ({
                required String text,
                TextStyle? textStyle,
              }) {
                return TextSpan(
                  text: text,
                  style: (textStyle ?? const TextStyle()).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                    color: Colors.blueAccent,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                );
              },
            )
          ],
        ),
      ]
    );
  }
}