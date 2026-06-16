import 'package:actpod_web/features/package_detail_page/components/package_detail_widgets.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PackageDetailDesktopScreen extends ConsumerWidget {
  final PackageDetailController packageDetailController;

  const PackageDetailDesktopScreen({
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
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          const _DesktopTopBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1260),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(42, 28, 20, 52),
                        children: [
                          PackageCover(
                            imageUrl: package.packageImageUrl,
                            height: 280,
                            badgeSize: 15,
                          ),
                          const SizedBox(height: 24),
                          PackageDescriptionSection(package: package),
                          PackageStoriesSection(package: package),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 380,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 42, 52),
                        children: [
                          PackageInfoCard(package: package, packageDetailController: packageDetailController,),
                          const SizedBox(height: 24),
                          const PodCoinSummaryCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 42),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go("/explore"),
            child: Image.asset(
              "assets/images/actpod_logo_web.png",
              height: 36,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }
}
