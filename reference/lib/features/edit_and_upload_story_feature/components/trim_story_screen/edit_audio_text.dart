import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

class EditAudioText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(pagePositionProvider) == 0? "剪輯音檔" : "編輯音檔",
      style: TextStyle(
        fontSize: 24.w,
        color: Colors.white
      ),
    );
  }
}