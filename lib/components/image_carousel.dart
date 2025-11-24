import 'package:actpod_web/design_system/color.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NetworkImageCarousel extends ConsumerStatefulWidget {
  final List<String> imageUrls;

  const NetworkImageCarousel({super.key, required this.imageUrls});

  @override
  ConsumerState<NetworkImageCarousel> createState() =>
      _NetworkImageCarouselState();
}

class _NetworkImageCarouselState
    extends ConsumerState<NetworkImageCarousel> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 340.w,
            aspectRatio: 1,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.only(right: 4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: CustomNetworkImage(
                        url: url,
                        fit: BoxFit.cover,
                        customLoadingBuilder: (context, child, event) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange, // 👈 change to whatever color you like
                            ),
                          );
                        },
                      ),
                    ),
                  )
                );
              },
            );
          }).toList(),
        ),

        // Indicator (e.g. "1/2") on top-right
        Visibility(
          visible: widget.imageUrls.length > 1,
          child: Positioned(
            top: 8.w,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Text(
                "${_currentIndex + 1}/${widget.imageUrls.length}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ),
      ],
    );
  }
}