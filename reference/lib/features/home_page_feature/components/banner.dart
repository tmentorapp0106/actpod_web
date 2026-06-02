import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ActPodBanner extends ConsumerStatefulWidget {
  const ActPodBanner({super.key});

  @override
  ConsumerState<ActPodBanner> createState() => _ActPodBannerState();
}

class _ActPodBannerState extends ConsumerState<ActPodBanner> {
  int _current = 0; // for indicator
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bannerUrls = ref.read(bannerUrlProvider);
    for (final url in bannerUrls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerUrls = ref.watch(bannerUrlProvider);

    return SliverToBoxAdapter(
      child: bannerUrls.isEmpty
          ? const SizedBox.shrink()
          : Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.w),
          child: Container(
            height: (ScreenUtil().screenWidth - 32.w) * 10 / 16,
            width: ScreenUtil().screenWidth - 32.w,
            color: Colors.white,
            child: Stack(
              children: [
                /// Carousel
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: bannerUrls.length,
                  options: CarouselOptions(
                    height: (ScreenUtil().screenWidth - 32.w) * 10 / 16,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 8),
                    enableInfiniteScroll: bannerUrls.length > 1,
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                      ref.watch(currentBannerIndicatorProvider.notifier).state = index;
                    },
                  ),
                  itemBuilder: (context, i, realIdx) {
                    return Container(
                      width: ScreenUtil().screenWidth - 32.w,
                      height: (ScreenUtil().screenWidth - 32.w) * 10 / 16,
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          bannerUrls[i],
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Text(
                              "Image not available",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                /// Indicator
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: PageController(
                          initialPage: _current), // dummy, sync below
                      count: bannerUrls.length,
                      effect: WormEffect(
                        dotHeight: 8.w,
                        dotWidth: 8.w,
                        radius: 8.w,
                        activeDotColor: Colors.white,
                        paintStyle: PaintingStyle.fill,
                        dotColor: const Color(0xFFffffff).withOpacity(0.3),
                      ),
                      onDotClicked: (index) {
                        _carouselController.animateToPage(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}