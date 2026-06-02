import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/providers.dart'; // 提供 DesignColor.primary50

class StoryEmptyView extends ConsumerWidget {
  const StoryEmptyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 若你的專案已在上層初始化 ScreenUtil，這裡可直接用 .w/.h/.sp
    final primary = DesignColor.primary50; // 橘色主色（可改你們自己的）
    final textDefault = ConfigColor.textColorDefault; // 你的預設文字色
    final hint = Colors.grey; // 次要提示色

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: ref.watch(mainPlayerStoryInfoProvider) != null? 400.h : 460.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      '上傳故事後\n等待聽眾留言',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: hint.withOpacity(0.9),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    SvgPicture.asset('assets/icons/voice_message/point.svg',
                        width: 64.w),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
