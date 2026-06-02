
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/voice_message_page_feature/controllers/likes_controller.dart';
import 'package:quick_share_app/features/voice_message_page_feature/controllers/story_controller.dart';
import 'package:quick_share_app/features/voice_message_page_feature/providers.dart';

import '../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../config/color.dart';
import '../../providers.dart';
import 'components/about_story.dart';
import 'components/send_message_button.dart';
import 'components/story_info_bar.dart';
import 'components/like_button.dart';
import 'components/user_info.dart';
import 'components/voice_message_list.dart';
import 'components/voice_message_list_title.dart';
import 'controllers/message_response_player_controller.dart';
import 'controllers/voice_message_controller.dart';

class VoiceMessagePageScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String storyOwnerId;
  final String collaboratorId;

  VoiceMessagePageScreen(this.storyId, this.storyOwnerId, this.collaboratorId);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VoiceMessagePageScreenState();
  }
} 

class VoiceMessagePageScreenState extends ConsumerState<VoiceMessagePageScreen> {
  ScrollController scrollController = ScrollController();
  StoryController? storyController;
  MessageResponsePlayerController? messagePlayerController;
  VoiceMessageController? voiceMessageController;
  LikesController? likesController;

  @override
  void initState() {
    super.initState();
    storyController = StoryController(ref);
    messagePlayerController = MessageResponsePlayerController(ref);
    voiceMessageController = VoiceMessageController(ref);
    likesController = LikesController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.watch(loadingProvider.notifier).state = true;
      likesController!.getCount(widget.storyId);
      likesController!.checkExist(widget.storyId);
      await storyController!.getStoryInfo(widget.storyId);
      await voiceMessageController!.getStoryVoiceMessage(widget.storyId, widget.storyOwnerId, widget.collaboratorId);
      ref.watch(loadingProvider.notifier).state = false;
      await messagePlayerController!.preparePlayer();

      // scroll to specific voice message
      // RenderBox box = ref.watch(voiceMessageWidgetKey)[0].currentContext?.findRenderObject() as RenderBox;
      // Offset position = box.localToGlobal(Offset.zero); //this is global position
      //
      // scrollController.animateTo(position.dy - ScreenUtil().screenHeight / 2, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  @override
  void dispose() {
    messagePlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 32.h,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20.h,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          surfaceTintColor: ConfigColor.background,
          centerTitle: true,
          backgroundColor: ConfigColor.background,
          elevation: 0
        ),
        backgroundColor: ConfigColor.background,
        body: Stack(
          children: [
            SafeArea(
              child: storyInfo == null? const SizedBox.shrink() : SingleChildScrollView(
                controller: scrollController,
                physics: BouncingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: ScreenUtil().screenHeight - 50.h
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h,),
                      Container(
                        padding: EdgeInsets.only(top: 12.h, bottom: 8.h, left: 16.w, right: 16.w),
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: DesignSystem.shadow,
                          borderRadius: BorderRadius.circular(15.w)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StoryInfoBarWidget(),
                            SizedBox(height: 8.h,),
                            AboutStory(),
                            Divider(
                              thickness: 0.5.w,
                              height: 16.h,
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                SendMessageButton(storyInfo),
                                SizedBox(width: 4.w,),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h,),
                      VoiceMessageListTitle(),
                      SizedBox(height: 8.h,),
                      VoiceMessageList(messagePlayerController!),
                      SizedBox(height: 115.h,)
                    ],
                  ),
                )
              ),
            ),
          ],
        )
      )
    );
  }
}