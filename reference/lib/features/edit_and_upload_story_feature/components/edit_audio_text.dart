import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

class EditAudioText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String text = "編輯故事";
    if(ref.watch(pagePositionProvider) == 0) {
      if(ref.watch(cutFromProvider) != null) {
        text = "剪輯中...";
      } else {
        text = "剪輯音檔";
      }
    } else if(ref.watch(pagePositionProvider) == 3) {
      text = "選擇精華";
    } else if(ref.watch(pagePositionProvider) == 4) {
      text = "付費設定";
    } else if(ref.watch(pagePositionProvider) == 5) {
      text = "預覽";
    } else {
      text = "編輯故事";
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 24.w,
        fontWeight: FontWeight.bold,
        color: ref.watch(pagePositionProvider) < 2? Colors.white : Colors.black
      ),
    );
  }
}