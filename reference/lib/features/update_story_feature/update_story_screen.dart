import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/update_story_feature/components/channel_drop_down.dart';
import 'package:quick_share_app/features/update_story_feature/components/collaborator.dart';
import 'package:quick_share_app/features/update_story_feature/components/complete_btn.dart';
import 'package:quick_share_app/features/update_story_feature/components/description.dart';
import 'package:quick_share_app/features/update_story_feature/components/image.dart';
import 'package:quick_share_app/features/update_story_feature/components/shorts.dart';
import 'package:quick_share_app/features/update_story_feature/components/space_drop_down.dart';
import 'package:quick_share_app/features/update_story_feature/components/title.dart';
import 'package:quick_share_app/features/update_story_feature/controllers/shorts_controller.dart';
import 'package:quick_share_app/features/update_story_feature/controllers/story_controller.dart';
import 'package:quick_share_app/features/update_story_feature/provider.dart';
import 'package:quick_share_app/providers.dart';

import '../../config/color.dart';
import '../../design_system/color.dart';
import 'controllers/list_controller.dart';

class UpdateStoryScreen extends ConsumerStatefulWidget {
  final String storyId;

  UpdateStoryScreen(this.storyId);

  @override
  ConsumerState<UpdateStoryScreen> createState() {
    return UpdateStoryScreenState();
  }
}

class UpdateStoryScreenState extends ConsumerState<UpdateStoryScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  StoryController? storyController;
  ListController? listController;
  ShortsController? shortsController;

  @override
  void initState() {
    super.initState();
   storyController = StoryController(ref);
   listController = ListController(ref);
   shortsController = ShortsController(ref);
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      shortsController!.getStoryShorts(widget.storyId);
      await listController!.getChannels();
      await listController!.getSpaces();
      await storyController!.getStory(widget.storyId);
      if(ref.watch(storyProvider) != null) {
        titleController.text = ref.watch(storyProvider)!.storyName;
        descriptionController.text = ref.watch(storyProvider)!.storyDescription;

        ref.watch(channelSelectionProvider.notifier).state = ref.watch(storyProvider)!.channelName;

        final spaceList = ref.watch(spaceListProvider);
        ref.watch(spaceSelectionProvider.notifier).state = spaceList.firstWhere((space) => space.spaceId == ref.watch(storyProvider)!.spaceId).name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            "編輯故事"
          ),
        ),
        body: SingleChildScrollView(
          child: ref.watch(storyProvider) == null? const Center(
            child: CircularProgressIndicator(
              color: DesignColor.primary50,
            ),
          ) : content()
        )
      )
    );
  }

  Widget content() {
    return Column(
        children: [
          StoryImage(),
          SizedBox(height: 20.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "故事標題",
                ),
                SizedBox(height: 8.h,),
                TitleTextField(titleController),
                SizedBox(height: 12.h,),
                Text(
                  "故事敘述",
                ),
                SizedBox(height: 8.h,),
                DescriptionTextField(descriptionController)
              ],
            )
          ),
          SizedBox(height: 12.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "故事空間",
                ),
                SizedBox(height: 8.h,),
                SpaceDropDown(),
                SizedBox(height: 12.h,),
                Text(
                  "頻道選擇",
                ),
                SizedBox(height: 8.h,),
                ChannelDropDown(),
                SizedBox(height: 12.h,),
                Shorts(shortsController: shortsController!, storyId: widget.storyId),
                SizedBox(height: 12.h,),
                Collaborator(listController: listController!),
              ],
            )
          ),
          SizedBox(height: 20.h,),
          CompleteButton(
            widget.storyId,
            titleController,
            descriptionController,
            storyController!
          ),
          SizedBox(
            height: ref.watch(mainPlayerStoryInfoProvider) == null? 100.h : 160.h,
          ),
        ]
    );
  }
}