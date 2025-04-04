import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WebStoryImage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyInfo = ref.watch(storyInfoProvider);
    return storyInfo == null? const SizedBox.shrink() : ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network( 
        storyInfo.storyImageUrl,
        width: 44.w,
        height: 44.w,
        fit: BoxFit.fitWidth,
      )
    );
  }
}