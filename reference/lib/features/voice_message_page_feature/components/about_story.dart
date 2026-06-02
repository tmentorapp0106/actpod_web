import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/utils/link_utils.dart';
import 'package:quick_share_app/utils/time_utils.dart';
import 'package:readmore/readmore.dart';

import '../../../design_system/color.dart';
import '../providers.dart';

class AboutStory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(storyInfo!.storyUploadTime),
        SizedBox(height: 4.h,),
        description(storyInfo!.storyDescription)
      ],
    );
  }

  Widget title(DateTime uploadTime) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "關於這則單集",
          style: TextStyle(
              fontSize: 16.w,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 8.w,),
        Text(
          TimeUtils.convertToFormat("yyyy/MM/dd", uploadTime),
          style: TextStyle(
            fontSize: 12.w
          ),
        ),
        // todo: space name
        // Container(
        //   decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(20.w),
        //       color: Colors.black26.withOpacity(0.05)
        //   ),
        //   padding: EdgeInsets.only(left: 10.w, top: 4.h, right: 10.w, bottom: 6.h), // for Mandarin
        //   child: Text(
        //     spaceName,
        //     textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
        //     style: TextStyle(
        //       fontSize: 12.w,
        //     ),
        //   )
        // ),
      ],
    );
  }

  Widget description(String description) {
    return ReadMoreText(
      description,
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
    );
  }
}