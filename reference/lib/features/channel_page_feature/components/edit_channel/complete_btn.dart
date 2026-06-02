import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/providers.dart';

class CompleteChannelBtn extends ConsumerWidget {
  final ChannelController channelController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  CompleteChannelBtn(
    this.channelController,
    this.nameController,
    this.descriptionController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final channelInfo = ref.watch(channelInfoProvider);
        final selectedImage = ref.watch(selectedChannelImageProvider);
        ref.watch(loadingProvider.notifier).state = true;
        await channelController.updateChannelInfo(
            selectedImage,
            channelInfo!.channelId,
            nameController.text,
            descriptionController.text,
        );
        ref.watch(loadingProvider.notifier).state = false;
        if(context.mounted) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(30.w),
      child: Container(
        width: 96.w,
        height: 40.h,
        decoration: BoxDecoration(
            color: DesignColor.primary50,
            borderRadius: BorderRadius.circular(30.w)
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Center(
          child: AutoSizeText(
            "完成",
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.white
            )
          ),
        ),
      )
    );
  }
}