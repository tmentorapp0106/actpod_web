import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/stepper_nav.dart';

import '../../../config/color.dart';
import '../../../utils/image_utils.dart';
import '../providers.dart';

class TitleAndDescriptionPage extends ConsumerWidget {

  TitleAndDescriptionPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h,),
                  const StepperNav(currentStep: 0),
                  SizedBox(height: 20.h,),
                  title("故事標題"),
                  SizedBox(height: 4.h,),
                  titleTextField(ref),
                  SizedBox(height: 12.h,),
                  title("故事敘述"),
                  SizedBox(height: 4.h,),
                  descriptionTextField(ref),
                  SizedBox(height: 10.h,),
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  title("故事空間"),
                  SizedBox(height: 4.h,),
                  spaceDropDown(ref),
                  SizedBox(height: 10.h,),
                  title("頻道選擇"),
                  SizedBox(height: 4.h,),
                  channelDropDown(ref),
                  SizedBox(height: 10.h,),
                  title("上傳圖片"),
                  SizedBox(height: 4.h,),
                  ref.watch(storyImagesProvider) == null? uploadWidget(ref) : imageWidget(ref),
                  SizedBox(height: 4.h,),
                  Text(
                    "格式: jpg, png",
                    style: TextStyle(
                        fontSize: 10.w
                    ),
                  ),
                  SizedBox(height: 60.h,),
                ],
              )
            ),
          ]
        )
      )
    );
  }

  Widget singleImage(File file) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      child: SizedBox(
          width: 120.w,
          height: 120.w,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.file(
                    file,
                  )
              )
          )
      ),
    );
  }

  Widget imageWidget(WidgetRef ref) {
    if(ref.watch(storyImagesProvider)!.length < 2) {
      return GestureDetector(
        onTap: () async {
          List<File>? selectFile = await ImageUtils.pickMultipleMedia(fromGallery: true, cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720), maxCount: 10) ;
          ref.watch(storyImagesProvider.notifier).state = selectFile;
        },
        child: SizedBox(
          width: 150.w,
          height: 150.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.w),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.file(
                ref.watch(storyImagesProvider)![0],
              )
            )
          )
        )
      );
    } else {
      List<Widget> images = [];
      for(int i = 0; i < ref.watch(storyImagesProvider)!.length; i++) {
        images.add(singleImage(ref.watch(storyImagesProvider)![i]));
      }
      return GestureDetector(
        onTap: () async {
          List<File>? selectFile = await ImageUtils.pickMultipleMedia(fromGallery: true, cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720), maxCount: 10) ;
          ref.watch(storyImagesProvider.notifier).state = selectFile;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(8.w)
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...images
              ],
            )
          ),
        )
      );
    }
  }

  Widget title(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: DesignColor.neutral600,
            fontWeight: FontWeight.bold
          ),
        )
      ]
    );
  }

  Widget uploadWidget(WidgetRef ref) {
    return InkWell(
      onTap: () async {
        List<File>? selectFile = await ImageUtils.pickMultipleMedia(fromGallery: true, cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720), maxCount: 10) ;
        ref.watch(storyImagesProvider.notifier).state = selectFile;
      },
      child: Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(15.w),
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: DesignColor.neutral50
              ),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_rounded,
                  size: 16.w,
                ),
                Text(
                  "上傳",
                  style: TextStyle(
                    fontSize: 16.w
                  ),
                )
              ],
            )
          )
        )
      )
    );
  }

  Widget titleTextField(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(
          color: DesignColor.neutral300
        )
      ),
      width: 350.w,
      child: TextField(
        maxLines: 1,
        controller: ref.watch(storyNameEditingControllerProvider),
        style: TextStyle(
          color: ConfigColor.textColorDefault,
          fontSize: 16.w
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6.h),
          hintText: "輸入標題",
          hintStyle: TextStyle(
            color: Colors.grey
          )
        ),
      )
    );
  }

  Widget descriptionTextField(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: DesignColor.neutral300
        )
      ),
      width: 350.w,
      child: TextField(
        maxLines: 9,
        controller: ref.watch(storyDescriptionEditingControllerProvider),
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          color: ConfigColor.textColorDefault,
          fontSize: 16.w
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          hintText: "輸入敘述 (800字以內)",
          hintStyle: TextStyle(
              color: Colors.grey
          )
        ),
      )
    );
  }

  Widget spaceDropDown(WidgetRef ref) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        isDense: true,
      ),
      hint: const Text(
        'Select Your Space',
        style: TextStyle(fontSize: 14),
      ),
      value: ref.watch(spaceSelectionProvider),
      items: ref.watch(spaceListProvider).map((item) => DropdownMenuItem<String>(
        value: item.name,
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        )).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select story space.';
        }
        return null;
      },
      onChanged: (value) {
        ref.watch(spaceSelectionProvider.notifier).state = value;
      },
      onSaved: (value) {
        // selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: DesignColor.neutral300,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget channelDropDown(WidgetRef ref) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        isDense: true,
      ),
      hint: const Text(
        'Select Your Channel',
        style: TextStyle(fontSize: 14),
      ),
      value: ref.watch(channelSelectionProvider),
      items: ref.watch(channelListProvider).map((item) => DropdownMenuItem<String>(
        value: item.channelName,
        child: Text(
          item.channelName,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      )).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select channel.';
        }
        return null;
      },
      onChanged: (value) {
        ref.watch(channelSelectionProvider.notifier).state = value;
      },
      onSaved: (value) {
        // selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: DesignColor.neutral300,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}