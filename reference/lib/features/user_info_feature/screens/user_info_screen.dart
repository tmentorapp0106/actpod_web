import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_feature/components/membership.dart';
import 'package:quick_share_app/features/user_info_feature/components/user_info.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/coins_and_cash_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/download_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/membership_controller.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/story_controller.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/user_service.dart';
import '../components/description.dart';
import '../components/edit_personal_info.dart';
import '../components/story_channel_tab_view.dart';
import '../controllers/user_info_controller.dart';
import '../providers.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserInfoScreen> createState() {
    return UserInfoScreenState();
  }
}

class UserInfoScreenState extends ConsumerState<UserInfoScreen> with TickerProviderStateMixin {
  UserInfoController? _userInfoController;
  StoryController? _storyAndCollectionController;
  CoinsAndCashController? _coinsAndCashController;
  MembershipController? _membershipController;
  ChannelController? _channelController;
  TabController? _controller;
  DownloadController? _downloadController;

  @override
  void initState() {
    super.initState();
    _userInfoController = UserInfoController(ref);
    _coinsAndCashController = CoinsAndCashController(ref);
    _storyAndCollectionController = StoryController(ref);
    _channelController = ChannelController(ref);
    _membershipController = MembershipController(ref);
    _downloadController = DownloadController();
    _controller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      ref.watch(syncProcessingProvider.notifier).state = false;
      ref.watch(loadingProvider.notifier).state = false;
      if(UserService.getUserToken() == null || UserService.getUserToken() == "") {
        _userInfoController!.clearUserInfo();
        _storyAndCollectionController!.clearStories();
        _channelController!.clearChannels();
        ref.watch(loadingProvider.notifier).state = false;
        return;
      } else {
        try {
          _coinsAndCashController!.getUserPurses();
          await Future.wait([
            _userInfoController!.getUserInfo(),
            _membershipController!.getMembership(),
            _membershipController!.getMembershipPrice(),
            _membershipController!.getMembershipLevelInfos(),
            _storyAndCollectionController!.getStories(UserService.getUserInfo()!.userId),
            _storyAndCollectionController!.getStoryCount(UserService.getUserInfo()!.userId),
            _storyAndCollectionController!.checkSyncing(),
            _channelController!.getChannels(UserService.getUserInfo()!.userId)
          ]);
        } catch(e) {
          print(e);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        backgroundColor: ConfigColor.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Column(
              children:[
                Membership(_membershipController!),
                UserInfoWidget(_coinsAndCashController!),
                Description(),
                EditPersonalInfo(_userInfoController!, _membershipController!),
                SizedBox(height: 5.h,),
                StoryChannelTabView(_controller!, false, _storyAndCollectionController!, _downloadController!, _channelController!),
              ]
            )
          )
        )
      )
    );
  }
}