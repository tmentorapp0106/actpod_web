import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/explore_page/main_page.dart';
import 'package:actpod_web/features/package_purchase_fail/controllers/package_purchase_fail_controller.dart';
import 'package:actpod_web/features/package_purchase_fail/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackagePurchaseFailPage extends ConsumerStatefulWidget {
  final String packageId;

  const PackagePurchaseFailPage({
    super.key,
    required this.packageId,
  });

  @override
  ConsumerState<PackagePurchaseFailPage> createState() =>
      _PackagePurchaseFailPageState();
}

class _PackagePurchaseFailPageState
    extends ConsumerState<PackagePurchaseFailPage> {
  late final PackagePurchaseFailController controller;

  @override
  void initState() {
    super.initState();
    controller = PackagePurchaseFailController(ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPackageInfo(widget.packageId);
    });
  }

  @override
  void didUpdateWidget(covariant PackagePurchaseFailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageId != widget.packageId) {
      controller.getPackageInfo(widget.packageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;

        return _PackagePurchaseFailView(isDesktop: isDesktop);
      },
    );
  }
}

class _PackagePurchaseFailView extends ConsumerWidget {
  final bool isDesktop;

  const _PackagePurchaseFailView({
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(packagePurchaseFailProvider);
    final loading = ref.watch(packagePurchaseFailLoadingProvider);
    final error = ref.watch(packagePurchaseFailErrorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final verticalPadding = isDesktop ? 80.0 : 20.0;
            final minContentHeight = constraints.maxHeight > verticalPadding
                ? constraints.maxHeight - verticalPadding
                : 0.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 24,
                  vertical: isDesktop ? 40 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minContentHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: isDesktop ? 520 : 420),
                      child: _buildContent(
                        package,
                        loading,
                        error,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    PackageInfoWithStoriesItem? package,
    bool loading,
    String? error,
  ) {
    if (package == null && loading) {
      return const Center(
        child: CircularProgressIndicator(color: DesignColor.primary50),
      );
    }

    if (package == null) {
      return _ErrorState(message: error);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/images/actpod_logo_web.png",
          height: isDesktop ? 42 : 34,
          fit: BoxFit.fitHeight,
        ),
        SizedBox(height: isDesktop ? 34 : 28),
        _PackageImage(
          imageUrl: package.packageImageUrl,
          maxHeight: isDesktop ? 292 : 190,
        ),
        SizedBox(height: isDesktop ? 32 : 28),
        const Icon(
          Icons.error_rounded,
          color: DesignColor.primary500,
          size: 48,
        ),
        const SizedBox(height: 18),
        const Text(
          "購買未完成",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DesignColor.neutral950,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "「${package.packageName}」購買未成功，請確認付款狀態後再試一次。",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: DesignColor.neutral600,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isDesktop ? 34 : 30),
        const Text(
          "與 ActPod 官方聯繫",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DesignColor.neutral600,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const SelectableText(
          "contact.us@actpodapp.com",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DesignColor.neutral950,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PackageImage extends StatelessWidget {
  final String imageUrl;
  final double maxHeight;

  const _PackageImage({
    required this.imageUrl,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: DesignColor.neutral50),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: DesignColor.neutral400,
                    size: 42,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;

  const _ErrorState({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: DesignColor.neutral400,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            "無法載入購買資訊",
            style: TextStyle(
              color: DesignColor.neutral950,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DesignColor.neutral600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
