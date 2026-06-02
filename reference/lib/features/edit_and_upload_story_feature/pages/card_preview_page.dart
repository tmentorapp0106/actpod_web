
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/story_card.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

import '../../../dto/channel_dto.dart';
import '../components/stepper_nav.dart';
import '../dto/upload_preview_dto.dart';

class CardPreviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ChannelDto channelDto = ref.watch(channelListProvider).where((channel) => channel.channelName == ref.watch(channelSelectionProvider)!).first;
    UploadPreviewDto uploadPreviewDto = UploadPreviewDto(
      ref.watch(collaboratorProvider) == null? "" : ref.watch(collaboratorProvider)!.userId,
      ref.watch(collaboratorProvider) == null? "" : ref.watch(collaboratorProvider)!.nickname,
      ref.watch(collaboratorProvider) == null? "" : ref.watch(collaboratorProvider)!.avatarUrl,
      ref.watch(storyImagesProvider),
      ref.watch(storyNameEditingControllerProvider).text,
      channelDto.channelName,
      channelDto.channelImageUrl,
      ref.watch(spaceSelectionProvider)!,
      ref.watch(storyDescriptionEditingControllerProvider).text,
      "",
      ref.watch(totalLengthProvider),
      ref.watch(podcoinSettingProvider) != 0
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8.h,),
            const StepperNav(currentStep: 3),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
              child: StoryCard(
                0,
                uploadPreviewDto: uploadPreviewDto,
              )
            ),
            SizedBox(height: 48.h,),
          ]
        )
      )
    );
  }
}