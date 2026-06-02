import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/image_utils.dart';
import '../provider.dart';

class StoryImage extends ConsumerWidget {
  const StoryImage({super.key});

  Future<void> _pick(WidgetRef ref) async {
    final picked = await ImageUtils.pickMultipleMedia(
      fromGallery: true,
      cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720),
      maxCount: 10,
    );
    if (picked != null && picked.isNotEmpty) {
      ref.read(selectedStoryImageProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(selectedStoryImageProvider) ?? const <File>[];
    final story = ref.watch(storyProvider)!; // you said non-null & non-empty
    const double singleSize = 150; //
    const double multiSize  = 150; // 120.w if you prefer
    const double singleR    = 20;  // 20.w
    const double multiR     = 15;  // 15.w

    // No local picks → show network cover (single or multiple)
    if (files.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        constraints: BoxConstraints.tightFor(height: multiSize.w),
        child: InkWell(
          onTap: () => _pick(ref),
          child: NetworkImagesPreview(
            urls: story.storyImageUrls,
            singleSize: singleSize.w,
            multiItemSize: multiSize.w,
            radius: singleR.w,
          ),
        ),
      );
    }

    // One local image → single preview (fixed size)
    if (files.length == 1) {
      return InkWell(
        onTap: () => _pick(ref),
        child: SizedBox(
          width: singleSize.w,
          height: singleSize.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(singleR.w),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(files.first, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }

    // 2+ images → horizontal scroll (fixed tile size)
    return InkWell(
      onTap: () => _pick(ref),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x1F000000)),
          borderRadius: BorderRadius.circular(12.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: multiSize.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: files.length,
            separatorBuilder: (_, __) => SizedBox(width: 6.w),
            itemBuilder: (_, i) => _SingleImage(
              file: files[i],
              url: null,
              size: multiSize.w,
              radius: multiR.w,
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleImage extends StatelessWidget {
  final File? file;
  final String? url;
  final double size;
  final double radius;

  const _SingleImage({
    super.key,
    required this.file,
    required this.url,
    required this.size,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (size * dpr).round();
    final targetH = (size * dpr).round();

    Widget child;
    if (file != null) {
      child = Image.file(
        file!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      );
    } else {
      child = Image.network(
        url!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        // Ask the image cache/decoder for an image close to our display size
        cacheWidth: targetW,
        cacheHeight: targetH,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Color(0x11000000),
          child: Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child, // no AspectRatio needed; tile is already square
      ),
    );
  }
}

class NetworkImagesPreview extends StatelessWidget {
  final List<String> urls;     // non-empty
  final double singleSize;
  final double multiItemSize;
  final double radius;

  const NetworkImagesPreview({
    super.key,
    required this.urls,
    required this.singleSize,
    required this.multiItemSize,
    required this.radius,
  }) : assert(urls.length > 0);

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return SizedBox(
        width: singleSize,
        height: singleSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              urls.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0x11000000),
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: singleSize,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x1F000000)),
        borderRadius: BorderRadius.circular(12.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: multiItemSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: urls.length,
          separatorBuilder: (_, __) => SizedBox(width: 6.w),
          itemBuilder: (_, i) => SizedBox(
            width: singleSize - 20.w, // padding
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              clipBehavior: Clip.antiAlias, // ensure clipping
              child: Image.network(
                urls[i],
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          )
        ),
      ),
    );
  }
}
