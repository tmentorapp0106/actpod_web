import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
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
            right: 12.w,
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

class FileImageCarousel extends ConsumerStatefulWidget {
  final List<File>? imageFiles;

  const FileImageCarousel({super.key, required this.imageFiles});

  @override
  ConsumerState<FileImageCarousel> createState() =>
      _FileImageCarouselState();
}

class _FileImageCarouselState
    extends ConsumerState<FileImageCarousel> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: widget.imageFiles != null,
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 336.w,
              aspectRatio: 1,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.imageFiles!.map((file) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      margin: EdgeInsets.only(right: 4.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.w),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  );
                },
              );
            }).toList(),
          )
        ),

        // Indicator (e.g. "1/2") on top-right
        Visibility(
            visible: widget.imageFiles != null && widget.imageFiles!.length > 1,
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
                  "${_currentIndex + 1}/${widget.imageFiles!.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.w,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
        ),

        // Your "試聽精華" bottom-left container
        Positioned(
          bottom: 8.w,
          left: 4.w,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                color: const Color(0xff222222).withOpacity(0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  Text(
                    "試聽精華",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}