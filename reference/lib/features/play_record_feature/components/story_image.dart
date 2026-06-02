import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/image_carousal.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';

class StoryImage extends ConsumerWidget {
  final PlayerItemDto storyInfo;

  StoryImage({required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 342.w,
      height: 342.w,
      child: NetworkImageCarousel(imageUrls: storyInfo.storyImageUrls),
    );
  }
}