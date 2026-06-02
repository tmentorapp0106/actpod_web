import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/home_page_feature/components/announcement_banner.dart';
import 'package:quick_share_app/features/home_page_feature/components/live_room_section.dart';
import 'package:quick_share_app/features/home_page_feature/components/personal_section.dart';
import 'package:quick_share_app/features/home_page_feature/components/space_section.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/live_controller.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/record_wall_controller.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/space_controller.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/features/user_info_feature/screens/other_user_info_screen.dart';

import '../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../components/policy_agreement_dialog.dart';
import '../../config/color.dart';
import '../../dto/live_room_dto.dart';
import '../../main.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../services/page_router_service.dart';
import '../../shared_prefs/agreement_prefs.dart';
import '../space_selection_feature/providers.dart';
import '../space_story_feature/providers.dart';
import '../space_story_feature/space_story_screen.dart';
import '../user_info_feature/providers.dart';
import 'components/banner.dart';
import 'components/record_list.dart';
import 'components/search_bar.dart';
import 'controllers/announcement_controller.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  final scrollController;
  final String? storyId;

  HomePageScreen({this.storyId, required this.scrollController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return HomePageScreenState();
  }
}

class HomePageScreenState extends ConsumerState<HomePageScreen> with RouteAware, WidgetsBindingObserver {
  final PageController pageController = PageController();
  late Timer _autoPlayTimer;
  RecordWallController? recordWallController;
  AnnouncementController? announcementController;
  SpaceController? spaceController;
  LiveController? liveController;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _autoPlayTimer.cancel();
    pageController.dispose();
    previewPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        previewPlayerController.stop(ref, force: true);
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _startAutoPlayBanner() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (pageController.hasClients) {
        int nextPage = ref.watch(bannerUrlProvider).isEmpty? 0 : (ref.watch(currentBannerIndicatorProvider) + 1) % ref.watch(bannerUrlProvider).length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlayBanner();
    WidgetsBinding.instance.addObserver(this);
    recordWallController = RecordWallController(ref);
    announcementController = AnnouncementController(ref);
    spaceController = SpaceController(ref);
    liveController = LiveController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProvider();
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      announcementController!.init();
      spaceController!.getSpaces();
      recordWallController!.init();
      liveController!.getLiveRooms();
      await recordWallController!.getRecords();
      previewPlayerController.reset(ref, PreviewPage.home);
      if(AgreementPrefs.getContentPolicyAgreement() == null || AgreementPrefs.getContentPolicyAgreement() == false) {
        showDialog(
          context: context,
          builder: (context) {
            return PolicytAgreementDialog();
          }
        );
      }
      checkAndRouteToStory();
    });
  }

  void initProvider() {
    ref.watch(mainPageIndexProvider.notifier).state = 0;
    ref.watch(loadingProvider.notifier).state = false;
    ref.watch(currentBannerIndicatorProvider.notifier).state = 0;
    ref.watch(activeRoomsProvider.notifier).state = [];
  }
  
  Future<void> checkAndRouteToStory() async {
    if(widget.storyId != null) {
      GetOneStoryRes storyRes = await storyApiManager.getOneStory(widget.storyId!);
      if(storyRes.code != "0000") {
        return;
      }
      PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
      previewPlayerController.stop(ref, force: true);
      List<PlayerItemDto> playList = [playItem];
      router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (b, d) async {
        ref.watch(spaceStoriesProvider.notifier).state = [];
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: NestedScrollView(
            controller: widget.scrollController,
            hitTestBehavior: HitTestBehavior.translucent,
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo_transparent.png',
                              width: 40.w,
                              height: 40.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "ActPod",
                              style: TextStyle(
                                fontSize: 20.w,
                                fontWeight: FontWeight.bold,
                                color: DesignColor.primary50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 12.w,
                        top: 0,
                        bottom: 4,
                        child: IconButton(
                          icon: Icon(Icons.search, color: DesignColor.neutral600, size: 24.w),
                          onPressed: () {
                            router.push("/search");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // ActPodBanner(), // announcement banner
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  collapsedHeight: 80.h,
                  backgroundColor: ConfigColor.background,
                  flexibleSpace: PersonalSection(),
                ),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  collapsedHeight: 120.w,
                  backgroundColor: ConfigColor.background,
                  flexibleSpace: SpaceSection(),
                ),
                ref.watch(activeRoomsProvider).isEmpty? const SliverToBoxAdapter(child: SizedBox.shrink()) : SliverAppBar(
                  automaticallyImplyLeading: false,
                  collapsedHeight: 186.h,
                  backgroundColor: ConfigColor.background,
                  flexibleSpace: LiveRoomSection(liveController: liveController!,),
                ),
              ];
            },
            body: Container(
              color: ConfigColor.background,
              child: RecordWallList(recordWallController!, liveController!, AnnouncementBanner())
            ),
          )
        )
      )
    );
  }
}
