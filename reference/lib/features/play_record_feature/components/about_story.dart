import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/providers.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/link_utils.dart';
import 'package:quick_share_app/utils/time_utils.dart';
import 'package:readmore/readmore.dart';

import '../../../providers.dart';
import '../../../utils/string_utils.dart';

class AboutStory extends ConsumerWidget {
  final PlayerItemDto storyInfo;

  AboutStory({required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        title(ref, storyInfo.storyUploadTime, storyInfo.spaceName),
        SizedBox(height: 12.h,),
        description(storyInfo.storyDescription)
      ],
    );
  }

  Widget title(WidgetRef ref, DateTime releaseTime, String spaceName) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "關於這則故事",
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 8.w,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                  color: DesignColor.neutral100,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                  spaceName
              ),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(
                "assets/icons/home_page/headphones.svg",
                width: 14.w,
                height: 14.w,
                fit: BoxFit.fitWidth,
                color: DesignColor.neutral70
            ),
            SizedBox(width: 2.w,),
            Text(
              StringUtils.approximateNumberString(storyInfo.count),
              style: TextStyle(
                  fontSize: 10.sp,
                  color: DesignColor.neutral70
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              TimeUtils.convertToFormat("yyyy/MM/dd", releaseTime),
              style: TextStyle(
                  fontSize: 12.w
              ),
            ),
          ],
        )
      ]
    );
  }

  // Widget contentSwitch(WidgetRef ref) {
  //   final isPlayingInteractiveContent = ref.watch(isPlayingInteractiveContentProvider);
  //   return Visibility(
  //     visible: ref.watch(interactiveMessageInfoListProvider) != null && ref.watch(interactiveMessageInfoListProvider)!.isNotEmpty,
  //     child: GestureDetector(
  //       onTap: () {
  //         if(actPodAudioHandler?.mediaItem.value?.id != storyInfo.storyId) {
  //           ToastService.showNoticeToast("請先開始收聽此故事");
  //           return;
  //         }
  //         if(isPlayingInteractiveContent) {
  //           actPodAudioHandler?.playFromIndex(0);
  //         } else {
  //           actPodAudioHandler?.playFromIndex(1);
  //         }
  //       },
  //       child: Text(
  //         isPlayingInteractiveContent? "收聽正片" : "收聽留言"
  //       )
  //     )
  //   );
  // }

  Widget description(String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Expanded(
              child: ReadMoreText(
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
              )
            )
          ],
        )
      ),
    );
  }
}