import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/search_channel_res.dart';
import 'package:quick_share_app/config/color.dart';

class EmptyView extends ConsumerWidget {
  final String type; // 'channel' | 'story' | 'user'
  final TextEditingController textController;
  const EmptyView(
      {super.key, required this.type, required this.textController});

  String get _message {
    switch (type) {
      case 'story':
        return '找不到相關故事';
      case 'user':
        return '找不到相關 Podcaster';
      case 'channel':
      default:
        return '找不到相關頻道';
    }
  }
 
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if ( textController.text == "") {
      return Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: Center(
          child: AutoSizeText(
            "請輸入關鍵字進行搜尋",
            style: TextStyle(
              fontSize: 16.sp,
              color: ConfigColor.textColorDefault,
            ),
            maxLines: 1,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: Center(
          child: AutoSizeText(
            _message,
            style: TextStyle(
              fontSize: 16.sp,
              color: ConfigColor.textColorDefault,
            ),
            maxLines: 1,
          ),
        ),
      );
    }
  }
}
