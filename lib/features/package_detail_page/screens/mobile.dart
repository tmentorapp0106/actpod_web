import 'package:actpod_web/features/package_detail_page/components/package_detail_widgets.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PackageDetailMobileScreen extends ConsumerWidget {
  final PackageDetailController packageDetailController;
  
  const PackageDetailMobileScreen({
    super.key,
    required this.packageDetailController
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(packageDetailProvider);
    final loading = ref.watch(packageDetailLoadingProvider);
    final error = ref.watch(packageDetailErrorProvider);

    if (package == null && loading) {
      return const PackageDetailLoading();
    }
    if (package == null) {
      return PackageDetailError(message: error);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/explore");
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          "套裝詳情",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ToastService.showNoticeToast("分享功能尚未開放");
            },
            icon: const Icon(Icons.ios_share, color: Colors.black87),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const PodCoinSummaryCard(compact: true),
          const SizedBox(height: 14),
          PackageCover(
            imageUrl: package.packageImageUrl,
            height: 118,
            badgeSize: 12,
          ),
          const SizedBox(height: 10),
          PackageInfoCard(
            package: package,
            packageDetailController: packageDetailController,
            compact: true,
          ),
          const SizedBox(height: 14),
          PackageDescriptionSection(package: package),
          PackageStoriesSection(
            package: package,
            compact: true,
          ),
        ],
      ),
    );
  }
}
