import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/update_story_feature/controllers/story_controller.dart';

import '../../../design_system/color.dart';
import '../../../providers.dart';
import '../provider.dart';

class CompleteButton extends ConsumerWidget {
  final String storyId;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final StoryController storyController;

  CompleteButton(this.storyId, this.titleController, this.descriptionController, this.storyController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
        onTap: () async {
          if(titleController.text == "" || descriptionController.text == "") {
            return;
          }
          ref.watch(loadingProvider.notifier).state = true;
          final success = await storyController.updateStory(
            ref.watch(selectedStoryImageProvider),
            storyId,
            titleController.text,
            descriptionController.text,
            ref.watch(channelSelectionProvider),
            ref.watch(spaceSelectionProvider),
            ref.watch(collaboratorProvider)?.userId,
          );
          ref.watch(loadingProvider.notifier).state = false;
          if(success && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        borderRadius: BorderRadius.circular(30.w),
        child: Container(
          width: 96.w,
          height: 40.h,
          decoration: BoxDecoration(
              color: DesignColor.primary50,
              borderRadius: BorderRadius.circular(30.w)
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: Center(
            child: AutoSizeText(
              "完成",
              style: TextStyle(
                fontSize: 16.w,
                color: Colors.white
              )
            ),
          ),
        )
    );
  }
}