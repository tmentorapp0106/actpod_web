import 'dart:async';

import 'package:actpod_web/features/explore_page/controllers/user_controller.dart';
import 'package:actpod_web/features/explore_page/main_page.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/screens/desktop.dart';
import 'package:actpod_web/features/package_detail_page/screens/mobile.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/meta_tracking_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  StreamSubscription<User?>? _authStateSubscription;
  String? _syncedFirebaseUid;

  @override
  void initState() {
    super.initState();
    packageDetailController = PackageDetailController(ref);
    userController = UserController(ref);
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChange);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _restoreStoredUser();
      MetaTrackingService.instance.trackViewContent(
        pageName: 'Yuma 夏季旅遊日文速成班',
        contentId: widget.packageId,
        contentType: 'package',
      );
      packageDetailController.getPackageInfo(widget.packageId);
      await Future.delayed(const Duration(seconds: 1));
      packageDetailController.checkPurchased(widget.packageId);
    });
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    if (!mounted) {
      return;
    }

    if (firebaseUser == null) {
      if (!AuthService.isLoggedIn()) {
        _clearUserState();
        packageDetailController.checkPurchased(widget.packageId);
      }
      return;
    }

    if (_syncedFirebaseUid == firebaseUser.uid && AuthService.isLoggedIn()) {
      return;
    }

    try {
      final userInfo = await AuthService.syncFirebaseUser(firebaseUser);
      if (!mounted || userInfo == null) {
        return;
      }

      _syncedFirebaseUid = firebaseUser.uid;
      ref.read(userInfoProvider.notifier).state = userInfo;
      userController.getUserPurses();
      packageDetailController.checkPurchased(widget.packageId);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _clearUserState();
      packageDetailController.checkPurchased(widget.packageId);
    }
  }

  void _restoreStoredUser() {
    final userInfo = UserPrefs.getUserInfo();
    if (!AuthService.isLoggedIn() || userInfo == null) {
      UserPrefs.cleanUser();
      _clearUserState();
      return;
    }

    ref.watch(userInfoProvider.notifier).state = userInfo;
    userController.getUserPurses();
  }

  void _clearUserState() {
    ref.watch(userInfoProvider.notifier).state = null;
    ref.watch(userPodCoinsProvider.notifier).state = 0;
  }

  @override
  void didUpdateWidget(covariant PackageDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageId != widget.packageId) {
      packageDetailController.checkPurchased(widget.packageId);
      packageDetailController.getPackageInfo(widget.packageId);
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;

        if (isDesktop) {
          return PackageDetailDesktopScreen(
            packageDetailController: packageDetailController,
          );
        }

        return PackageDetailMobileScreen(
            packageDetailController: packageDetailController);
      },
    );
  }
}
