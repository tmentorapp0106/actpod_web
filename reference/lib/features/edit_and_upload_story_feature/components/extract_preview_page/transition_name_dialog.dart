import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/transition_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';

class TransitionNameDialog {
  final TransitionController transitionController;
  final File transitionFile;

  TransitionNameDialog(
    this.transitionController,
    this.transitionFile
  );

  Future<void> show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: SizedBox(
                  height: 240.h,
                  child: Stack(
                    children: [
                      inputName(context, ref, _controller),
                      loading(ref),
                      // Close button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.close, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            );
          }
        );
      },
    );
  }

  Widget loading(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(transitionLoadingProvider),
      child: Center(
        child: SizedBox(
          height: 36.w,
          width: 36.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(DesignColor.primary50),
          ),
        )
      )
    );
  }

  Widget inputName(BuildContext context, WidgetRef ref, TextEditingController controller) {
    return Visibility(
      visible: !ref.watch(transitionLoadingProvider),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h), // Spacer for the X button
            Text(
              '轉場音樂名稱',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '請輸入名稱',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: DesignColor.primary50,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final name = controller.text.trim();
                  if(name == "") {
                    return;
                  }
                  ref.watch(transitionLoadingProvider.notifier).state = true;
                  await transitionController.uploadTransition(transitionFile, name);
                  await transitionController.getTransitionList();
                  ref.watch(transitionLoadingProvider.notifier).state = false;
                  Navigator.pop(context); // Dismiss dialog
                },
                label: Text('上傳'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  backgroundColor: DesignColor.primary50,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}