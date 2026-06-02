import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

import 'components/listened_voice_message_list.dart';
import 'components/story_voice_message_list.dart';
import 'controllers/voice_message_controller.dart';

class VoiceMessageNoticePageScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VoiceMessageNoticePageScreenState();
  }
}

class VoiceMessageNoticePageScreenState extends ConsumerState<VoiceMessageNoticePageScreen>  with TickerProviderStateMixin {
  late final TabController _tabController;
  VoiceMessageController? _voiceMessageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _voiceMessageController = VoiceMessageController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.watch(loadingProvider.notifier).state = false;
      if(!UserService.hasLoggedIn()) {
        return;
      }
      _voiceMessageController!.getVoiceMessages(context, false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _voiceMessageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.w,
          title: Text(
            '語音留言動態',
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold,
              color: ConfigColor.textColorDefault
            ),
          ),
          centerTitle: true,
          backgroundColor: ConfigColor.background,
          surfaceTintColor: ConfigColor.background,
          elevation: 0,
        ),
        backgroundColor: ConfigColor.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48.h,
                child: TabBar(
                  overlayColor: WidgetStateProperty.all(DesignColor.actpodPrimary400.withOpacity(0.12)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3,
                      color: DesignColor.actpodPrimary400
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      text: '你的故事'
                    ),
                    Tab(
                      text: '收聽的故事'
                    ),
                  ],
                )
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    StoryVoiceMessageList(),
                    ListenedVoiceMessageList()
                  ],
                )
              ),
              SizedBox(height: 60.h,)
            ],
          )
        ),
      )
    );
  }
}