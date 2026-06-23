import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/personal_page/controllers/channel_controller.dart';
import 'package:actpod_web/features/personal_page/controllers/story_controller.dart';
import 'package:actpod_web/features/personal_page/controllers/user_controller.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:actpod_web/features/personal_page/screens/desktop.dart';
import 'package:actpod_web/features/personal_page/screens/mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalScreen extends ConsumerStatefulWidget {
  final String userId;

  const PersonalScreen({required this.userId});

  @override
  _PersonalScreenState createState() => _PersonalScreenState();
}

class _PersonalScreenState extends ConsumerState<PersonalScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    UserInfoDto? userInfo = ref.watch(userInfoProvider);
    Widget body;
    if (userInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = isPhone
          ? MobilePersonalScreen(tabController: _tabController!)
          : DesktopPersonalScreen(tabController: _tabController!);
    }
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: body,
    );
  }
}
