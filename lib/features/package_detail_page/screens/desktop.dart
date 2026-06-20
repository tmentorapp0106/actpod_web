import 'package:actpod_web/features/package_detail_page/components/actpod_download_widget.dart';
import 'package:actpod_web/features/package_detail_page/components/package_cover.dart';
import 'package:actpod_web/features/package_detail_page/components/package_description_section.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_state_views.dart';
import 'package:actpod_web/features/package_detail_page/components/package_info_card.dart';
import 'package:actpod_web/features/package_detail_page/components/package_stories_section.dart';
import 'package:actpod_web/features/package_detail_page/components/podcoin_summary_card.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PackageDetailDesktopScreen extends ConsumerWidget {
  final PackageDetailController packageDetailController;

  const PackageDetailDesktopScreen(
      {super.key, required this.packageDetailController});

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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(42, 28, 42, 52),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 40),
                        SizedBox(
                          width: 380,
                          child: Column(
                            children: [
                              PackageInfoCard(
                                package: package,
                                packageDetailController:
                                    packageDetailController,
                              ),
                              const SizedBox(height: 24),
                              PodCoinSummaryCard(
                                packageDetailController:
                                    packageDetailController,
                                packageId: package.packageId,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const ActPodDownloadWidget(),
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
