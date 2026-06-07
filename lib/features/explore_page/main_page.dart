import 'package:actpod_web/features/explore_page/controllers/package_controller.dart';
import 'package:actpod_web/features/explore_page/controllers/story_controller.dart';
import 'package:actpod_web/features/explore_page/controllers/user_controller.dart';
import 'package:actpod_web/features/explore_page/screens/desktop.dart';
import 'package:actpod_web/features/explore_page/screens/mobile.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  StoryController? storyController;
  UserController? userController;
  PackageController? packageController;

  @override
  void initState() {
    super.initState();
    storyController = StoryController(ref);
    userController = UserController(ref);
    packageController = PackageController(ref);

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if(!AuthService.isLoggedIn() || UserPrefs.getUserInfo() == null) {
        UserPrefs.cleanUser();
      } else {
        ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
        userController?.getUserPurses();
      }
      storyController?.getRecommendation();
      packageController?.getPackages();
    });
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;

        if (isDesktop) {
          return const ExploreDesktopScreen();
        }

        return const ExploreMobileScreen();
      },
    );
  }
}