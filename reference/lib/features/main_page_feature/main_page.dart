import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/components/mini_player.dart';
import 'package:quick_share_app/features/main_page_feature/controller/player_controller.dart';
import 'package:quick_share_app/features/tutorial.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/preload_service.dart';
import 'package:quick_share_app/shared_prefs/tutorial_prefs.dart';
import 'package:quick_share_app/utils/device_utils.dart';

import '../../config/color.dart';
import '../../providers.dart';
import '../../services/upgrade_service.dart';
import '../../services/user_service.dart';

class MainPageScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainPageScreen(this.child, {super.key});

  @override
  ConsumerState<MainPageScreen> createState() {
    return MainPageScreenState();
  }

}

class MainPageScreenState extends ConsumerState<MainPageScreen> {
  PlayerController? playerController;
  Stream<Uri?>? deepLinkStream;

  @override
  void initState() {
    super.initState();
    playerController = PlayerController(ref);
    playerController!.initStreaming();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpgradeService.checkWithDialog(context);
      checkTutorialReadStats();
      if(UserService.hasLoggedIn()) {
        PreloadService.loadData(ref);
      }
    });
  }

  void checkTutorialReadStats() {
    if(TutorialPrefs.getTutorialReadStats() == null || TutorialPrefs.getTutorialReadStats() == "") {
      showDialog(
        context: context,
        builder: (context) {
          return Tutorial();
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: ref.watch(mainPageIndexProvider) == 1? Colors.black : Colors.white, // Android only (color of the status bar)
        statusBarIconBrightness: ref.watch(mainPageIndexProvider) == 1? Brightness.light : Brightness.dark, // icons = white
        statusBarBrightness: ref.watch(mainPageIndexProvider) == 1? Brightness.dark : Brightness.light, // iOS: text/icons handling
      ),
      child:PopScope(
        canPop: false,
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              widget.child,
              _bottomNavigatorBar(),
              MiniPlayer(
                bottomPadding: 80.h,
              ),
            ]
          )
        )
      )
    );
  }

  Widget _bottomNavigatorBar() {
    return Positioned(
      bottom: 0,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w), // adjust to your liking
              topRight: Radius.circular(20.w), // adjust to your liking
            ),
            color: ref.watch(mainPageIndexProvider) == 1? Colors.black : Colors.white, // put the color here
          ),
          height: 76.h,
          width: ScreenUtil().screenWidth,
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 8.sp,
            unselectedFontSize: 8.sp,
            iconSize: 20.w,
            selectedItemColor: ConfigColor.primaryDefault,
            unselectedItemColor: Colors.grey,
            currentIndex: ref.watch(mainPageIndexProvider),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (value) {
              switch(value) {
                case 0:
                  if(ref.watch(mainPageIndexProvider) == 0 ) {
                    homePageScrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeIn);
                  } else {
                    router.go("/");
                    ref.watch(mainPageIndexProvider.notifier).state = value;
                  }
                  break;
                case 1:
                  router.go("/shorts");
                  ref.watch(mainPageIndexProvider.notifier).state = value;
                  break;
                case 2:
                  router.go("/live_rooms");
                  ref.watch(mainPageIndexProvider.notifier).state = value;
                  break;
                case 3:
                  router.go("/voiceMessageNotice");
                  ref.watch(mainPageIndexProvider.notifier).state = value;
                  break;
                case 4:
                  router.go("/userInfo");
                  ref.watch(mainPageIndexProvider.notifier).state = value;
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/main_page/home.svg",
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/main_page/home.svg",
                  color: ConfigColor.primaryDefault,
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                ),
                label: '首頁',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.video_library_outlined,
                  size: 24.w,
                ),
                activeIcon: Icon(
                  Icons.video_library_outlined,
                  color: ConfigColor.primaryDefault,
                  size: 24.w,
                ),
                label: '短片',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/main_page/stream.svg",
                  color: Colors.grey,
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 26.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 26.w,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/main_page/stream.svg",
                  color: ConfigColor.primaryDefault,
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 26.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 26.w,
                ),
                label: '陪聽互動',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/main_page/voice_chat.svg",
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/main_page/voice_chat.svg",
                  color: ConfigColor.primaryDefault,
                  width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                ),
                label: '語音留言',
              ),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/main_page/account_circle.svg",
                    width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                    height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/icons/main_page/account_circle.svg",
                    color: ConfigColor.primaryDefault,
                    width: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                    height: DeviceUtils.isTablet(MediaQuery.of(context))? 14.w : 24.w,
                  ),
                  label: "帳號"
              ),
            ]
        )
      )
    );
  }

}