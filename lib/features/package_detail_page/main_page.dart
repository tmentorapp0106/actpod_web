import 'package:actpod_web/features/explore_page/controllers/user_controller.dart';
import 'package:actpod_web/features/explore_page/main_page.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/screens/desktop.dart';
import 'package:actpod_web/features/package_detail_page/screens/mobile.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageDetailPage extends ConsumerStatefulWidget {
  final String packageId;

  const PackageDetailPage({
    super.key,
    required this.packageId,
  });

  @override
  ConsumerState<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends ConsumerState<PackageDetailPage> {
  late final PackageDetailController packageDetailController;
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    packageDetailController = PackageDetailController(ref);
    userController = UserController(ref);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!AuthService.isLoggedIn() || UserPrefs.getUserInfo() == null) {
        UserPrefs.cleanUser();
      } else {
        ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
        userController.getUserPurses();
      }
      packageDetailController.checkPurchased(widget.packageId);
      packageDetailController.getPackageInfo(widget.packageId);
    });
  }

  @override
  void didUpdateWidget(covariant PackageDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageId != widget.packageId) {
      packageDetailController.getPackageInfo(widget.packageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;

        if (isDesktop) {
          return PackageDetailDesktopScreen(packageDetailController: packageDetailController,);
        }

        return PackageDetailMobileScreen(packageDetailController: packageDetailController);
      },
    );
  }
}
