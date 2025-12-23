import 'package:actpod_web/components/image_carousel.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MobileStoryImage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return Visibility(
      visible: ref.watch(playContentProvider) == PlayContent.story,
      child: storyInfo == null? const SizedBox.shrink() : NetworkImageCarousel(imageUrls: storyInfo.storyImageUrls)
    );
  }
}