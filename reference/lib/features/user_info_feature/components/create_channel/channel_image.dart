import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../../utils/image_utils.dart';
import '../../providers.dart';

class ChannelImage extends ConsumerWidget {
  const ChannelImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ref.watch(createChannelImageProvider) == null? uploadWidget(ref) : imageWidget(ref),
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

  Widget imageWidget(WidgetRef ref) {
    return InkWell(
        onTap: () async {
          File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 720, 720));
          ref.watch(createChannelImageProvider.notifier).state = selectFile;
        },
        child: SizedBox(
            width: 150.w,
            height: 150.w,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(0.w),
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.file(
                      ref.watch(createChannelImageProvider)!,
                    )
                )
            )
        )
    );
  }

  Widget uploadWidget(WidgetRef ref) {
    return InkWell(
        onTap: () async {
          File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 720, 720));
          ref.watch(createChannelImageProvider.notifier).state = selectFile;
        },
        child: Container(
            width: 150.w,
            height: 150.w,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(15.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 44.w,
                ),
                Text(
                  "上傳圖片",
                  style: TextStyle(
                      fontSize: 16.w
                  ),
                )
              ],
            )
        )
    );
  }
}