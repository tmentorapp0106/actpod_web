import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/extract_preview_page/transition_bottom_sheet.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/transition_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';

import '../../../../dto/block_info_dto.dart';
import '../../../../dto/transition_dto.dart';

class TransitionFile extends ConsumerWidget {
  final TransitionController transitionController;

  TransitionFile(this.transitionController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              color: DesignColor.neutral600,
              size: 20.w
            ),
            Text(
              "轉場音樂",
              style: TextStyle(
                color: DesignColor.neutral600,
              )
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                TransitionDto? transition = await TransitionBottomSheet(transitionController).show(context);
                transitionController.stopTransition();
                if(transition != null) {
                  ref.watch(transitionSelectedProvider.notifier).state = transition;
                }
              },
              child: Text(
                "選擇",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: DesignColor.primary50,
                  fontSize: 14.w
                ),
              )
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            ref.watch(transitionSelectedProvider) == null? "無" : ref.watch(transitionSelectedProvider)!.name,
            style: TextStyle(
              fontSize: 16.sp,
              color: DesignColor.neutral600
            ),
          )
        )
      ],
    );
  }
}