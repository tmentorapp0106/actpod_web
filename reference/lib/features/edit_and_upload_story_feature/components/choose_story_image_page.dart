import 'dart:io';

import 'package:dotted_border/dotted_border.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../l10n/app_localizations.dart';

import '../../../config/color.dart';
import '../../../utils/image_utils.dart';
import '../providers.dart';

class ChooseStoryImagePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(height: 60.h,),
        InkWell(
          onTap: () async {
            List<File>? selectFiles = await ImageUtils.pickMultipleMedia(fromGallery: true, cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720), maxCount: 10);
            ref.watch(storyImagesProvider.notifier).state = selectFiles;
          },
          child: ref.watch(storyImagesProvider) == null? selectImage(context, ref) : storyImage(ref.watch(storyImagesProvider)!)
        )
      ],
    );
  }

  Widget selectImage(BuildContext context, WidgetRef ref) {
    return db.DottedBorder(
      options: db.RoundedRectDottedBorderOptions(
        radius: Radius.circular(12.w),
        color: Colors.grey,
        dashPattern: [5.w, 2.w],
        strokeWidth: 1.w,
        // optional:
        // padding: const EdgeInsets.all(1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Container(
          height: 220.w,
          width: 220.w,
          color: ConfigColor.backgroundThird,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 50.w,
                  color: ConfigColor.textColorDefault,
                ),
                SizedBox(height: 10.h),
                Text(
                  AppLocalizations.of(context)!.uploadPicture,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ConfigColor.textColorDefault
                  ),
                )
              ],
            )
          )
        ),
      ),
    );
  }

  Widget storyImage(List<File> imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Image.file(
        imageFile[0],
        width: 220.w,
        height: 220.w,
        fit: BoxFit.fitWidth,
      )
    );
  }
}