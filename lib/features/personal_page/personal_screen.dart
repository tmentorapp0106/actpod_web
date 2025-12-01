import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/personal_page/components/story_channel_tab_view.dart';
import 'package:actpod_web/features/personal_page/components/user_info.dart';
import 'package:actpod_web/features/personal_page/components/web_logo.dart';
import 'package:actpod_web/features/personal_page/controllers/channel_controller.dart';
import 'package:actpod_web/features/personal_page/controllers/story_controller.dart';
import 'package:actpod_web/features/personal_page/controllers/user_controller.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:actpod_web/features/player_page/components/launch_deep_link_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalScreen extends ConsumerStatefulWidget {
  final String userId;

  const PersonalScreen({required this.userId});

  @override
  _PersonalScreenState createState() => _PersonalScreenState();
}

class _PersonalScreenState extends ConsumerState<PersonalScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  UserController? userController;
  StoryController? storyController;
  ChannelController? channelController;
  @override
  void initState() {
    super.initState();
    userController = UserController(ref: ref);
    storyController = StoryController(ref: ref);
    channelController = ChannelController(ref: ref);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController!.getOtherUserInfo(widget.userId);
      storyController!.getStories(widget.userId);
      storyController!.getStoryCount(widget.userId);
      channelController!.getChannels(widget.userId);
    });
  }

  // Future<void> checkOpenDeepLink() async {
  //   String url;
  //   if(kIsWeb) {
  //     bool? goto = await showDialog<bool>(
  //       context: context,
  //       builder: (context) => LaunchDeepLinkDialog(),
  //     );
  //     if(goto != null && goto) {
  //       await Future.delayed(const Duration(microseconds: 500));
  //       url = "https://actpod-488af.web.app/story/link/${widget.storyId}?openExternalBrowser=1";
  //       if (await canLaunchUrl(Uri.parse(url))) {
  //         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //       } else {
  //         debugPrint("Could not launch $url");
  //       }
  //     }
  //   }
  // }

  void initProviders() {
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    UserInfoDto? userInfo = ref.watch(userInfoProvider);
    Widget body;
    if(userInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = isPhone? mobileScreen() : Center(
        child: Text("此頁面僅支援手機瀏覽器觀看"),
      );
    }
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: SizedBox(
        child: body
      )
    );
  }

  Widget webScreen() {
    return Center(
      child: Text("此頁面僅支援手機瀏覽器觀看"),
    );
  }

  Widget mobileScreen() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Column(
            children:[
              WebLogo(),
              UserInfoWidget(),
              StoryChannelTabView(_tabController!),
            ]
          )
        )
      )
    );
  }
}