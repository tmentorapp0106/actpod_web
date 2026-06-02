import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

import '../../../../utils/image_utils.dart';

class ChannelImage extends ConsumerWidget {
  ChannelImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ref.watch(selectedChannelImageProvider) == null? originalImageWidget(ref) : selectedImageWidget(ref),
        SizedBox(height: 4.h,),
        Text(
          "格式: jpg, png",
          style: TextStyle(
              fontSize: 10.w
          ),
        )
      ],
    );
  }

  Widget selectedImageWidget(WidgetRef ref) {
    return InkWell(
        onTap: () async {
          File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 720, 720));
          ref.watch(selectedChannelImageProvider.notifier).state = selectFile;
        },
        child: SizedBox(
            width: 150.w,
            height: 150.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.w),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.file(
                  ref.watch(selectedChannelImageProvider)!,
                )
              )
            )
        )
    );
  }

  Widget originalImageWidget(WidgetRef ref) {
    return InkWell(
        onTap: () async {
          File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 720, 720)) as File?;
          ref.watch(selectedChannelImageProvider.notifier).state = selectFile;
        },
        child: SizedBox(
            width: 150.w,
            height: 150.w,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(0.w),
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(
                      ref.watch(editChannelImageUrlProvider)!,
                    )
                )
            )
        )
    );
  }
}